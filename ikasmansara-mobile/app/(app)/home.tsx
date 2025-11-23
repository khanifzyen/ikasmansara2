import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuth } from '../../context/AuthContext';
import { useRouter } from 'expo-router';

export default function Home() {
    const { user, logout } = useAuth();
    const router = useRouter();

    const handleLogout = () => {
        logout();
        router.replace('/(auth)/login');
    };

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.content}>
                <Text style={styles.title}>Selamat Datang!</Text>
                <Text style={styles.subtitle}>Halo, {user?.name || user?.email}</Text>

                <View style={styles.card}>
                    <Text style={styles.cardText}>Ini adalah halaman Home (Placeholder)</Text>
                </View>

                <TouchableOpacity style={styles.btnLogout} onPress={handleLogout}>
                    <Text style={styles.btnText}>Keluar</Text>
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F9FAFB',
    },
    content: {
        flex: 1,
        padding: 24,
        justifyContent: 'center',
        alignItems: 'center',
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#006A4E',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
        color: '#6B7280',
        marginBottom: 40,
    },
    card: {
        backgroundColor: 'white',
        padding: 24,
        borderRadius: 16,
        width: '100%',
        alignItems: 'center',
        marginBottom: 40,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 15,
        elevation: 2,
    },
    cardText: {
        color: '#374151',
    },
    btnLogout: {
        backgroundColor: '#EF4444',
        paddingVertical: 12,
        paddingHorizontal: 30,
        borderRadius: 8,
    },
    btnText: {
        color: 'white',
        fontWeight: '600',
    },
});
