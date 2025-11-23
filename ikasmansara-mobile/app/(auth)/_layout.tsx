import { Stack } from 'expo-router';

export default function AuthLayout() {
    return (
        <Stack screenOptions={{ headerShown: false, animation: 'slide_from_right' }}>
            <Stack.Screen name="role-selection" />
            <Stack.Screen name="register-public" />
            <Stack.Screen name="register-alumni" />
            <Stack.Screen name="login" />
        </Stack>
    );
}
