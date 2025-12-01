#!/bin/bash

# Script to test different passwords for the manamana.jks keystore
KEYSTORE="/Users/dfs/Documents/mana/mana-mana_app/manamana.jks"
EXPECTED_SHA1="D5:81:8B:C3:C8:94:9E:93:35:E6:D6:3D:50:FA:09:7A:A1:FF:21:E1"

echo "========================================="
echo "Keystore Password Tester"
echo "========================================="
echo "Keystore: $KEYSTORE"
echo "Expected SHA1: $EXPECTED_SHA1"
echo ""

# Function to test a password
test_password() {
    local password="$1"
    echo -n "Testing password: '$password' ... "
    
    # Try to list the keystore
    result=$(keytool -list -v -keystore "$KEYSTORE" -storepass "$password" 2>&1)
    
    if echo "$result" | grep -q "keystore password was incorrect"; then
        echo "❌ WRONG"
        return 1
    elif echo "$result" | grep -q "Keystore type:"; then
        echo "✅ CORRECT!"
        echo ""
        echo "========================================="
        echo "SUCCESS! Password found: $password"
        echo "========================================="
        echo ""
        
        # Extract SHA1
        sha1=$(echo "$result" | grep "SHA1:" | head -1 | awk '{print $2}')
        echo "SHA1 Fingerprint: $sha1"
        echo ""
        
        # Check if it matches expected
        if [ "$sha1" = "$EXPECTED_SHA1" ]; then
            echo "🎉 THIS IS THE CORRECT KEYSTORE FOR GOOGLE PLAY!"
            echo ""
            echo "Update your key.properties with:"
            echo "storePassword=$password"
            echo "keyPassword=$password"
            echo "keyAlias=<check_output_above>"
            echo "storeFile=$KEYSTORE"
        else
            echo "⚠️  This keystore works but SHA1 doesn't match Google Play"
            echo "Expected: $EXPECTED_SHA1"
            echo "Got:      $sha1"
        fi
        
        # Show aliases
        echo ""
        echo "Available aliases in this keystore:"
        keytool -list -keystore "$KEYSTORE" -storepass "$password" 2>/dev/null
        
        return 0
    else
        echo "⚠️  UNKNOWN ERROR"
        return 1
    fi
}

# Test common passwords
echo "Testing common passwords..."
echo ""

passwords=(
    "Dfs123@"
    "manamana"
    "Manamana"
    "MANAMANA"
    "manamana123"
    "Manamana123"
    "Manamana123@"
    "dfs123"
    "Dfs123"
    "123456"
    "password"
    "mana"
    "mana123"
    ""
)

for pwd in "${passwords[@]}"; do
    if test_password "$pwd"; then
        exit 0
    fi
done

echo ""
echo "========================================="
echo "None of the common passwords worked."
echo "========================================="
echo ""
echo "You can manually test passwords by running:"
echo "keytool -list -v -keystore $KEYSTORE -storepass YOUR_PASSWORD"
echo ""
echo "Or enter a password to test now:"
read -s -p "Password: " user_password
echo ""
test_password "$user_password"
