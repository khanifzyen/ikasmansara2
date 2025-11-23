import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator } from 'react-native';
import { useRouter, Link } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import pb from '../../lib/pocketbase';
import { useAuth } from '../../context/AuthContext';

export default function Login() {
    const router = useRouter();
    const { login } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const handleLogin = async () => {
        if (!email || !password) {
            Alert.alert('Error', 'Mohon isi email dan password');
            return;
        }

        setLoading(true);
        try {
            await pb.collection('users').authWithPassword(email, password);
            login(); // Update context
            router.replace('/(app)/home');
        } catch (error: any) {
            console.error(error);
            Alert.alert('Gagal Masuk', 'Email atau password salah');
        } finally {
            setLoading(false);
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.content}>
                <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
                    <Text style={styles.backBtnText}>←</Text>
                </TouchableOpacity>

                <View style={styles.header}>
                    <Text style={styles.title}>Selamat Datang{'\n'}Kembali!</Text>
                    <Text style={styles.subtitle}>Silakan masuk untuk melanjutkan.</Text>
                </View>

                <View style={styles.form}>
                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Email / Username</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="Masukkan email atau username"
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Password</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="••••••••"
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />
                    </View>

                    <TouchableOpacity style={styles.forgotPass}>
                        <Text style={styles.forgotPassText}>Lupa Password?</Text>
                    </TouchableOpacity>

                    <TouchableOpacity
                        style={[styles.btnPrimary, loading && styles.btnDisabled]}
                        onPress={handleLogin}
                        disabled={loading}
                    >
                        {loading ? (
                            <ActivityIndicator color="white" />
                        ) : (
                            <Text style={styles.btnText}>Masuk</Text>
                        )}
                    </TouchableOpacity>
                </View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>Belum punya akun? </Text>
                    <Link href="/(auth)/role-selection" asChild>
                        <TouchableOpacity>
                            <Text style={styles.link}>Daftar</Text>
                        </TouchableOpacity>
                    </Link>
                </View>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    content: {
        flex: 1,
        padding: 24,
    },
    backBtn: {
        marginBottom: 20,
    },
    backBtnText: {
        fontSize: 24,
        color: '#1F2937',
    },
    header: {
        marginBottom: 40,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#006A4E',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 14,
        color: '#6B7280',
    },
    form: {
        gap: 20,
    },
    inputGroup: {
        gap: 8,
    },
    label: {
        fontSize: 14,
        fontWeight: '500',
        color: '#374151',
    },
    input: {
        borderWidth: 1,
        borderColor: '#E5E7EB',
        borderRadius: 8,
        padding: 12,
        fontSize: 16,
        color: '#1F2937',
    },
    forgotPass: {
        alignItems: 'flex-end',
    },
    forgotPassText: {
        fontSize: 13,
        color: '#006A4E',
        fontWeight: '500',
    },
    btnPrimary: {
        backgroundColor: '#006A4E',
        paddingVertical: 14,
        borderRadius: 8,
        alignItems: 'center',
        marginTop: 10,
    },
    btnDisabled: {
        opacity: 0.7,
    },
    btnText: {
        color: 'white',
        fontWeight: '600',
        fontSize: 16,
    },
    footer: {
        marginTop: 30,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
    },
    footerText: {
        fontSize: 14,
        color: '#6B7280',
    },
    link: {
        fontSize: 14,
        fontWeight: '600',
        color: '#006A4E',
    },
});
