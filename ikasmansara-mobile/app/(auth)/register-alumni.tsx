import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView, Alert, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import pb from '../../lib/pocketbase';
import Animated, { FadeInRight, FadeOutLeft } from 'react-native-reanimated';

import { useToast } from '../../context/ToastContext';

export default function RegisterAlumni() {
    const router = useRouter();
    const { showToast } = useToast();
    const [step, setStep] = useState(1);
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        whatsapp: '',
        password: '',
        passwordConfirm: '',
        graduationYear: '',
        homeroomTeacher: '',
        jobStatus: 'Swasta',
        company: '',
        domicile: '',
    });

    const updateForm = (key: string, value: string) => {
        setFormData(prev => ({ ...prev, [key]: value }));
    };

    const nextStep = () => {
        if (step === 1) {
            const missing = [];
            if (!formData.name) missing.push('Nama Lengkap');
            if (!formData.email) missing.push('Email');
            if (!formData.whatsapp) missing.push('No WhatsApp');
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
        } else if (step === 2) {
            if (!formData.graduationYear) {
                showToast('Mohon isi Tahun Lulus', 'warning');
                return;
            }
            if (formData.graduationYear.length !== 4) {
                showToast('Tahun Lulus harus 4 digit', 'warning');
                return;
            }
        }
        setStep(step + 1);
    };

    const prevStep = () => {
        setStep(step - 1);
    };

    const handleRegister = async () => {
        setLoading(true);
        try {
            const data = {
                username: formData.email.split('@')[0] + '_' + Math.floor(Math.random() * 1000),
                email: formData.email,
                emailVisibility: true,
                password: formData.password,
                passwordConfirm: formData.passwordConfirm,
                name: formData.name,
                role: 'alumni',
                whatsapp: formData.whatsapp,
                graduation_year: formData.graduationYear,
                homeroom_teacher: formData.homeroomTeacher,
                job_status: formData.jobStatus,
                company: formData.company,
                domicile: formData.domicile,
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

            showToast('Pendaftaran Berhasil! Silahkan tunggu verifikasi admin.', 'success');
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
            // Check for network error (status 0 usually indicates network issues in PocketBase SDK)
            else if (error.status === 0) {
                errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
            } else if (error.message) {
                errorMessage = error.message;
            }

            // Specific check for "Failed to fetch" which is common for network errors
            if (error.toString().includes('Failed to fetch') || error.toString().includes('Network request failed')) {
                errorMessage = 'Koneksi internet bermasalah atau server tidak dapat dijangkau.';
            }

            showToast(errorMessage, 'error');
        } finally {
            setLoading(false);
        }
    };

    const renderStep1 = () => (
        <Animated.View entering={FadeInRight} exiting={FadeOutLeft} style={styles.stepContainer}>
            <Text style={styles.stepTitle}>Buat Akun</Text>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Nama Lengkap</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Sesuai Ijazah"
                    value={formData.name}
                    onChangeText={(t) => updateForm('name', t)}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Email</Text>
                <TextInput
                    style={styles.input}
                    placeholder="contoh@email.com"
                    keyboardType="email-address"
                    autoCapitalize="none"
                    value={formData.email}
                    onChangeText={(t) => updateForm('email', t)}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>No WhatsApp</Text>
                <TextInput
                    style={styles.input}
                    placeholder="0812..."
                    keyboardType="phone-pad"
                    value={formData.whatsapp}
                    onChangeText={(t) => updateForm('whatsapp', t)}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Password</Text>
                <TextInput
                    style={styles.input}
                    placeholder="••••••••"
                    secureTextEntry
                    value={formData.password}
                    onChangeText={(t) => updateForm('password', t)}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Konfirmasi Password</Text>
                <TextInput
                    style={styles.input}
                    placeholder="••••••••"
                    secureTextEntry
                    value={formData.passwordConfirm}
                    onChangeText={(t) => updateForm('passwordConfirm', t)}
                />
            </View>
        </Animated.View>
    );

    const renderStep2 = () => (
        <Animated.View entering={FadeInRight} exiting={FadeOutLeft} style={styles.stepContainer}>
            <Text style={styles.stepTitle}>Data Sekolah</Text>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Tahun Lulus (Angkatan)</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Contoh: 2015"
                    keyboardType="number-pad"
                    maxLength={4}
                    value={formData.graduationYear}
                    onChangeText={(t) => updateForm('graduationYear', t.replace(/[^0-9]/g, ''))}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Wali Kelas Terakhir</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Nama Guru"
                    value={formData.homeroomTeacher}
                    onChangeText={(t) => updateForm('homeroomTeacher', t)}
                />
            </View>
        </Animated.View>
    );

    const renderStep3 = () => (
        <Animated.View entering={FadeInRight} exiting={FadeOutLeft} style={styles.stepContainer}>
            <Text style={styles.stepTitle}>Profil Saat Ini</Text>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Status Pekerjaan</Text>
                <View style={styles.pickerContainer}>
                    {['Swasta', 'PNS/BUMN', 'TNI/Polri', 'Wirausaha', 'Mahasiswa'].map((status) => (
                        <TouchableOpacity
                            key={status}
                            style={[
                                styles.catOption,
                                formData.jobStatus === status && styles.catOptionActive
                            ]}
                            onPress={() => updateForm('jobStatus', status)}
                        >
                            <Text style={[
                                styles.catText,
                                formData.jobStatus === status && styles.catTextActive
                            ]}>{status}</Text>
                        </TouchableOpacity>
                    ))}
                </View>
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Instansi / Perusahaan</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Tempat bekerja"
                    value={formData.company}
                    onChangeText={(t) => updateForm('company', t)}
                />
            </View>
            <View style={styles.inputGroup}>
                <Text style={styles.label}>Domisili (Kota)</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Kota tempat tinggal"
                    value={formData.domicile}
                    onChangeText={(t) => updateForm('domicile', t)}
                />
            </View>
        </Animated.View>
    );

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <TouchableOpacity onPress={() => router.back()}>
                    <Text style={styles.backBtnText}>← Kembali</Text>
                </TouchableOpacity>
                <View style={styles.progressContainer}>
                    <Text style={styles.progressText}>Langkah {step} dari 3</Text>
                    <View style={styles.progressBar}>
                        <View style={[styles.progressFill, { width: `${(step / 3) * 100}%` }]} />
                    </View>
                </View>
            </View>

            <ScrollView contentContainerStyle={styles.scrollContent}>
                {step === 1 && renderStep1()}
                {step === 2 && renderStep2()}
                {step === 3 && renderStep3()}
            </ScrollView>

            <View style={styles.footer}>
                {step > 1 && (
                    <TouchableOpacity style={styles.btnOutline} onPress={prevStep}>
                        <Text style={styles.btnOutlineText}>Kembali</Text>
                    </TouchableOpacity>
                )}

                {step < 3 ? (
                    <TouchableOpacity style={styles.btnPrimary} onPress={nextStep}>
                        <Text style={styles.btnText}>Lanjut</Text>
                    </TouchableOpacity>
                ) : (
                    <TouchableOpacity
                        style={[styles.btnPrimary, loading && styles.btnDisabled]}
                        onPress={handleRegister}
                        disabled={loading}
                    >
                        {loading ? (
                            <ActivityIndicator color="white" />
                        ) : (
                            <Text style={styles.btnText}>Daftar Sekarang</Text>
                        )}
                    </TouchableOpacity>
                )}
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    header: {
        padding: 24,
        paddingBottom: 0,
    },
    backBtnText: {
        fontSize: 16,
        color: '#1F2937',
        marginBottom: 16,
    },
    progressContainer: {
        marginBottom: 20,
    },
    progressText: {
        textAlign: 'right',
        fontSize: 12,
        color: '#6B7280',
        marginBottom: 8,
    },
    progressBar: {
        height: 6,
        backgroundColor: '#F3F4F6',
        borderRadius: 4,
        overflow: 'hidden',
    },
    progressFill: {
        height: '100%',
        backgroundColor: '#006A4E',
    },
    scrollContent: {
        padding: 24,
        paddingTop: 0,
    },
    stepContainer: {
        gap: 20,
    },
    stepTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: '#006A4E',
        marginBottom: 10,
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
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 8,
    },
    catOption: {
        borderWidth: 1,
        borderColor: '#E5E7EB',
        borderRadius: 8,
        padding: 10,
    },
    catOptionActive: {
        borderColor: '#006A4E',
        backgroundColor: '#EEFBF6',
    },
    catText: {
        fontSize: 13,
        color: '#6B7280',
    },
    catTextActive: {
        color: '#006A4E',
        fontWeight: '600',
    },
    footer: {
        padding: 24,
        borderTopWidth: 1,
        borderTopColor: '#F3F4F6',
        flexDirection: 'row',
        gap: 12,
    },
    btnPrimary: {
        flex: 1,
        backgroundColor: '#006A4E',
        paddingVertical: 14,
        borderRadius: 8,
        alignItems: 'center',
    },
    btnOutline: {
        flex: 1,
        borderWidth: 1,
        borderColor: '#E5E7EB',
        paddingVertical: 14,
        borderRadius: 8,
        alignItems: 'center',
    },
    btnText: {
        color: 'white',
        fontWeight: '600',
        fontSize: 16,
    },
    btnOutlineText: {
        color: '#374151',
        fontWeight: '600',
        fontSize: 16,
    },
    btnDisabled: {
        opacity: 0.7,
    },
});
