import { Slot } from 'expo-router';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { AuthProvider } from '../context/AuthContext';
import "../global.css";
import { StatusBar } from 'expo-status-bar';

import { ToastProvider } from '../context/ToastContext';

export default function RootLayout() {
    return (
        <GestureHandlerRootView style={{ flex: 1 }}>
            <AuthProvider>
                <ToastProvider>
                    <StatusBar style="dark" />
                    <Slot />
                </ToastProvider>
            </AuthProvider>
        </GestureHandlerRootView>
    );
}
