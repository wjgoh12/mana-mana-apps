# Debugging Guide for PWA Switch User Fix

This guide provides debugging code snippets and verification steps to ensure the switch user functionality is working correctly in PWA.

## Debug Code Snippet

If you want to add debugging to verify the switch is working, add this code to `owner_profile_v3_view.dart` after line 263 (after the `switchUserAndReload` call):

```dart
// TEMPORARY DEBUG CODE - Remove after verification
Future.delayed(const Duration(seconds: 2), () async {
  final currentUser = model.users.isNotEmpty ? model.users.first : null;
  debugPrint('🔍 POST-SWITCH DEBUG:');
  debugPrint('  - Current user email: ${currentUser?.email}');
  debugPrint('  - Current user name: ${currentUser?.ownerFullName}');
  debugPrint('  - Expected switched user: $email');
  debugPrint('  - Match: ${currentUser?.email == email ? "✅ SUCCESS" : "❌ FAILED"}');
  
  // Also check if GlobalDataManager has the right data
  final globalUser = GlobalDataManager().users.isNotEmpty 
      ? GlobalDataManager().users.first 
      : null;
  debugPrint('  - GlobalDataManager user: ${globalUser?.email}');
  debugPrint('  - GlobalDataManager match: ${globalUser?.email == email ? "✅" : "❌"}');
});
```

## Browser DevTools Verification

### 1. Check if Cookies are Being Sent

1. Open Chrome DevTools (F12)
2. Go to **Network** tab
3. Filter for "owners" (the getUsers API call)
4. Click on the request
5. Look at **Request Headers** section
6. **Verify**: "Cookie:" header is present ✅

### 2. Check Cookie Storage

1. Go to **Application** tab
2. Click **Cookies** in the left sidebar
3. Look for your domain (e.g., `admin.manamanasuites.com`)
4. **Verify**: Session cookies are present after switch-user call ✅

### 3. Monitor API Calls

In the DevTools Console, run:

```javascript
// View all cookies
document.cookie

// This should show session cookies after switching users
```

### 4. Check withCredentials is Working

1. In **Network** tab, click on any API request
2. Look at the request details
3. **Verify**: The request includes credentials (cookies are sent)

## Expected Behavior

### ✅ Correct Behavior (After Fix)

1. User clicks "Switch User" and enters target email
2. `/mobile/dash/admin/switch-user` API is called
3. **Backend sets session cookie** in response
4. Browser **stores the session cookie** (because of `withCredentials: true`)
5. Next API call `/mobile/dash/owners` is made
6. Browser **sends the session cookie** with the request
7. Backend sees the impersonation cookie and returns switched user's data
8. UI displays switched user's information

### ❌ Incorrect Behavior (Before Fix)

1. User clicks "Switch User" and enters target email
2. `/mobile/dash/admin/switch-user` API is called
3. Backend sets session cookie in response
4. Browser **ignores the cookie** (because `withCredentials` was not set)
5. Next API call `/mobile/dash/owners` is made
6. Browser **doesn't send any session cookie**
7. Backend returns original user's data (no impersonation context)
8. UI still shows original user's information ❌

## Console Logs to Watch For

When switching users, you should see these logs in the console:

```
🔁 validateSwitchUser response: {...}
✅ confirmSwitchUser response: {...}
🔄 User changed from original@email.com to switched@email.com - clearing cached data
🧹 Clearing cached data before refresh
📧 Current user set to: switched@email.com
✅ switchUserAndReload completed for switched@email.com
```

## Troubleshooting

### Issue: UI still shows original user after switch

**Check:**
1. Open Network tab and verify cookies are being sent
2. Check if backend CORS is configured correctly:
   - `Access-Control-Allow-Credentials: true`
   - `Access-Control-Allow-Origin: <specific-origin>` (not `*`)
3. Verify session cookies have proper flags:
   - `HttpOnly`
   - `Secure` (for HTTPS)
   - `SameSite=Lax` or `SameSite=None; Secure`

### Issue: CORS errors in console

**Solution:**
Backend needs to allow credentials. Check backend configuration:
- Must return `Access-Control-Allow-Credentials: true`
- Must return specific origin in `Access-Control-Allow-Origin` (cannot use `*` with credentials)

### Issue: Cookies not being stored

**Check:**
1. Browser settings - ensure cookies are not blocked
2. Try in incognito mode to rule out extensions
3. Verify the domain matches between app and API
4. Check if cookies have `Secure` flag but you're on HTTP (should be HTTPS)

## Additional Debug Logging

To add more detailed logging to the API service, you can temporarily uncomment the debug prints in `api_service.dart`:

```dart
// Around line 58
debugPrint('🔐 ApiService.post using token prefix: ${token.substring(0, min(10, token.length))}');

// Around line 64
debugPrint('🔐 ApiService.post decoded token payload: $decodedPayload');
```

This will help you verify which user's token is being used for API calls.

## Clean Up

After verifying the fix works:
1. Remove any temporary debug code added to `owner_profile_v3_view.dart`
2. Remove this debug documentation file if no longer needed
3. Keep the main fix documentation (`PWA_SWITCH_USER_FIX.md`) for reference
