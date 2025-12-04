import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView, Alert, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import pb from '../../lib/pocketbase';

import { useToast } from '../../context/ToastContext';

export default function RegisterPublic() {
    const router = useRouter();
    const { showToast } = useToast();
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        category: 'Masyarakat Umum',
        email: '',
        password: '',
        passwordConfirm: '',
    });

    const handleRegister = async () => {
        const missing = [];
        if (!formData.name) missing.push('Nama Lengkap');
        if (!formData.email) missing.push('Email');
        if (!formData.password) missing.push('Password');
        if (!formData.passwordConfirm) missing.push('Konfirmasi Password');

        if (missing.length > 0) {
            showToast(`Mohon isi: ${missing.join(', ')}`, 'warning');
            return;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(formData.email)) {
            showToast('Format email tidak valid', 'warning');
            return;
        }

        if (formData.password !== formData.passwordConfirm) {
            showToast('Password dan Konfirmasi Password tidak sama', 'error');
            return;
        }

        setLoading(true);
        try {
            // Create user
            const data = {
                username: formData.email.split('@')[0] + '_' + Math.floor(Math.random() * 1000),
                email: formData.email,
                emailVisibility: true,
                password: formData.password,
                passwordConfirm: formData.passwordConfirm,
                name: formData.name,
                role: 'public',
                category: formData.category,
            };

            const timeout = (ms: number) => new Promise((_, reject) => setTimeout(() => reject(new Error('Request timed out')), ms));

            // Create user with timeout
            await Promise.race([
                pb.collection('users').create(data),
                timeout(5000)
            ]);

            // Login automatically with timeout
            await Promise.race([
                pb.collection('users').authWithPassword(formData.email, formData.password),
                timeout(5000)
            ]);

            showToast('Akun berhasil dibuat', 'success');
            setTimeout(() => {
                router.replace('/(app)/home');
            }, 1500);
        } catch (error: any) {
            console.error(error);
            let errorMessage = 'Terjadi kesalahan saat mendaftar';

            // Check for timeout
            if (error.message === 'Request timed out') {
                errorMessage = 'Koneksi lambat. Gagal menghubungi server dalam 5 detik.';
            }
            // Check for network error
            else if (error.status === 0) {
                errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
            } else if (error.message) {
                errorMessage = error.message;
            }

            // Specific check for "Failed to fetch"
            if (error.toString().includes('Failed to fetch') || error.toString().includes('Network request failed')) {
                errorMessage = 'Koneksi internet bermasalah atau server tidak dapat dijangkau.';
            }

            showToast(errorMessage, 'error');
        } finally {
            setLoading(false);
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            <ScrollView contentContainerStyle={styles.scrollContent}>
                <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
                    <Text style={styles.backBtnText}>←</Text>
                </TouchableOpacity>

                <Text style={styles.title}>Daftar Akun Umum</Text>
                <Text style={styles.subtitle}>Dapatkan akses berita sekolah dan informasi donasi.</Text>

                <View style={styles.form}>
                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Nama Lengkap</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="Nama Lengkap"
                            value={formData.name}
                            onChangeText={(text) => setFormData({ ...formData, name: text })}
                        />
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Kategori</Text>
                        <View style={styles.pickerContainer}>
                            {['Guru / Staff Sekolah', 'Masyarakat Umum', 'Orang Tua Siswa'].map((cat) => (
                                <TouchableOpacity
                                    key={cat}
                                    style={[
                                        styles.catOption,
                                        formData.category === cat && styles.catOptionActive
                                    ]}
                                    onPress={() => setFormData({ ...formData, category: cat })}
                                >
                                    <Text style={[
                                        styles.catText,
                                        formData.category === cat && styles.catTextActive
                                    ]}>{cat}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Email</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="contoh@email.com"
                            keyboardType="email-address"
                            autoCapitalize="none"
                            value={formData.email}
                            onChangeText={(text) => setFormData({ ...formData, email: text })}
                        />
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Password</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="••••••••"
                            secureTextEntry
                            value={formData.password}
                            onChangeText={(text) => setFormData({ ...formData, password: text })}
                        />
                    </View>

                    <View style={styles.inputGroup}>
                        <Text style={styles.label}>Konfirmasi Password</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="••••••••"
                            secureTextEntry
                            value={formData.passwordConfirm}
                            onChangeText={(text) => setFormData({ ...formData, passwordConfirm: text })}
                        />
                    </View>

                    <TouchableOpacity
                        style={[styles.btnPrimary, loading && styles.btnDisabled]}
                        onPress={handleRegister}
                        disabled={loading}
                    >
                        {loading ? (
                            <ActivityIndicator color="white" />
                        ) : (
                            <Text style={styles.btnText}>Buat Akun</Text>
                        )}
                    </TouchableOpacity>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    scrollContent: {
        padding: 24,
    },
    backBtn: {
        marginBottom: 20,
    },
    backBtnText: {
        fontSize: 24,
        color: '#1F2937',
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#006A4E',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 14,
        color: '#6B7280',
        marginBottom: 30,
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
    pickerContainer: {
        gap: 8,
    },
    catOption: {
        borderWidth: 1,
        borderColor: '#E5E7EB',
        borderRadius: 8,
        padding: 12,
        alignItems: 'center',
    },
    catOptionActive: {
        borderColor: '#006A4E',
        backgroundColor: '#EEFBF6',
    },
    catText: {
        fontSize: 14,
        color: '#6B7280',
    },
    catTextActive: {
        color: '#006A4E',
        fontWeight: '600',
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
});
