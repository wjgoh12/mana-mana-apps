# PWA Switch User Fix - Summary

## Issue Description
When switching users in the PWA, the app would display the original user's data instead of the switched user's data, even though the switch operation appeared to succeed. This issue did not occur on mobile platforms.

## Root Cause Analysis

### How User Switching Works
1. Admin user initiates switch via `_showSwitchUserDialog()` in `owner_profile_v3_view.dart`
2. App validates the target user via `/mobile/dash/admin/valid-user` API
3. App confirms the switch via `/mobile/dash/admin/switch-user` API
4. **Backend sets a session cookie** to track the impersonation
5. Subsequent API calls should include this session cookie
6. Backend uses the session cookie to return the impersonated user's data

### The Problem
In `lib/provider/api_service.dart`, the cookie handling was different for web vs native:

**Mobile/Native (Working):**
- Uses `CookieManager` from `dio_cookie_manager` package
- Automatically stores and sends cookies with each request
- Session cookies from switch-user operation are properly maintained

**PWA/Web (Broken):**
- Cookie manager was disabled (lines 33-42)
- Comment said "For Web, we rely on Browser cookies"
- **However**, `withCredentials` was commented out
- Without `withCredentials: true`, browsers don't send/store cookies for cross-origin requests
- Session cookies from switch-user operation were **not being sent** with subsequent requests
- Backend received requests without the impersonation session cookie
- Backend returned the **original user's data** instead of the switched user's data

## The Fix

### Changes Made to `lib/provider/api_service.dart`

1. **Simplified constructor** (lines 31-48):
   - Removed the web-specific conditional logic
   - Set base options for all platforms
   - Keep CookieManager for native platforms only
   - Added comment explaining web cookie handling

2. **Added `withCredentials: true` to all Dio requests**:
   - `post()` method (line 97)
   - `postWithBytes()` method (line 165)
   - `postJson()` method (line 263)
   
   Each request now includes:
   ```dart
   extra: kIsWeb ? {'withCredentials': true} : {},
   ```

### Why This Works

When `withCredentials: true` is set in Dio's options for web:
1. The browser's Fetch API is instructed to include credentials (cookies) with the request
2. The browser will **send** existing cookies to the server
3. The browser will **store** new cookies received from the server
4. This enables proper session management for user impersonation

### Flow After Fix

1. Admin switches to user B
2. Backend sets session cookie: `impersonated_user=B`
3. App calls `/mobile/dash/owners` to fetch user data
4. **Browser now sends the session cookie** (because of `withCredentials: true`)
5. Backend sees the impersonation cookie and returns user B's data
6. App displays user B's data correctly ✅

## Testing Recommendations

1. **Test in PWA**:
   - Login as admin user (user A)
   - Switch to another user (user B)
   - Verify that the profile screen shows user B's data
   - Navigate to different screens and verify all data belongs to user B
   - Revert back to user A and verify data switches back

2. **Test in Mobile**:
   - Verify the fix doesn't break existing mobile functionality
   - Test the same switch user flow

3. **Check Browser DevTools**:
   - Open Network tab
   - Look for the `/mobile/dash/admin/switch-user` request
   - Verify cookies are being set in the response
   - Check subsequent API requests include the session cookie
   - Look for `Cookie:` header in request headers

## Additional Notes

### CORS Considerations
- The `withCredentials` setting requires proper CORS configuration on the backend
- Backend must respond with:
  - `Access-Control-Allow-Credentials: true`
  - `Access-Control-Allow-Origin` must be the specific origin (not `*`)
- If CORS errors occur, check backend CORS configuration

### Security
- Session cookies should have `HttpOnly` and `Secure` flags
- `SameSite` attribute should be configured appropriately
- This is a backend concern, not affected by this fix

### Alternative Approaches Considered
1. **Using localStorage instead of cookies**: Would require backend changes
2. **Passing impersonation token in headers**: Would require significant refactoring
3. **Using a different session management approach**: Would require backend changes

The current fix is minimal, maintains backward compatibility, and leverages existing backend session management.

## Files Modified
- `/Users/dfs/Documents/mana-refactor/mana-mana-apps/lib/provider/api_service.dart`

## Related Code (No Changes Needed)
- `lib/screens/profile/view/owner_profile_v3_view.dart` - Switch user UI
- `lib/screens/profile/view_model/owner_profile_view_model.dart` - Switch user logic
- `lib/repository/user_repo.dart` - API calls for switch user
- `lib/provider/global_data_manager.dart` - Data refresh logic (already handles user changes)
