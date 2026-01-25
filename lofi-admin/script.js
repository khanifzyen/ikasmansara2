// Admin Panel Shared Scripts

// Mock Data Store
const mockData = {
    users: [
        { id: 1, name: 'Budi Santoso', email: 'budi@email.com', angkatan: 2010, type: 'alumni', verified: true },
        { id: 2, name: 'Siti Aminah', email: 'siti@email.com', angkatan: 2015, type: 'alumni', verified: true },
        { id: 3, name: 'Ahmad Fauzi', email: 'ahmad@email.com', angkatan: null, type: 'public', verified: false },
        { id: 4, name: 'Dewi Lestari', email: 'dewi@email.com', angkatan: 2008, type: 'alumni', verified: false },
    ],
    events: [
        { id: 1, title: 'Jalan Sehat & Reuni Akbar 2026', date: '2026-08-20', location: 'Lapangan SMAN 1 Jepara', status: 'active' },
        { id: 2, title: 'Bakti Sosial Angkatan 2010', date: '2026-09-15', location: 'Panti Asuhan Al-Ikhlas', status: 'draft' },
    ],
    donations: [
        { id: 1, title: 'Renovasi Masjid Sekolah', target: 50000000, collected: 35000000, deadline: '2026-12-31', status: 'active' },
        { id: 2, title: 'Beasiswa Anak Tidak Mampu', target: 25000000, collected: 10000000, deadline: '2026-06-30', status: 'active' },
    ],
    news: [
        { id: 1, title: 'SMAN 1 Jepara Raih Juara Olimpiade Sains', date: '2026-01-20', status: 'published' },
        { id: 2, title: 'Launching Website Baru IKA SMANSARA', date: '2026-01-15', status: 'draft' },
    ],
    forum: [
        { id: 1, title: 'Tips Karir di Era Digital', author: 'Budi Santoso', replies: 24, status: 'active' },
        { id: 2, title: 'Ada yang ingat Bu Sari?', author: 'Siti Aminah', replies: 56, status: 'active' },
    ],
    loker: [
        { id: 1, title: 'Software Engineer', company: 'PT Tech Indo', status: 'pending' },
        { id: 2, title: 'Marketing Manager', company: 'CV Sejahtera', status: 'approved' },
    ],
    market: [
        { id: 1, title: 'Buku Alumni 2010', seller: 'Budi Santoso', price: 150000, status: 'pending' },
        { id: 2, title: 'Kerajinan Ukir Jepara', seller: 'Ahmad Fauzi', price: 500000, status: 'approved' },
    ],
    memory: [
        { id: 1, year: 1990, caption: 'Foto Kenangan Angkatan 1990', count: 24 },
        { id: 2, year: 2000, caption: 'Reuni Perak 2015', count: 56 },
        { id: 3, year: 2010, caption: 'Perpisahan Angkatan 2010', count: 120 },
    ]
};

// Utility Functions
function formatRupiah(amount) {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(amount);
}

function formatDate(dateString) {
    const options = { day: 'numeric', month: 'short', year: 'numeric' };
    return new Date(dateString).toLocaleDateString('id-ID', options);
}

// Navigation
function goBack() {
    history.back();
}

// Confirmation Modal
let confirmCallback = null;

function showConfirm(title, message, callback) {
    document.getElementById('confirmTitle').innerText = title;
    document.getElementById('confirmMessage').innerText = message;
    document.getElementById('confirmModal').classList.add('active');
    confirmCallback = callback;
}

function closeConfirm() {
    document.getElementById('confirmModal').classList.remove('active');
    confirmCallback = null;
}

function executeConfirm() {
    if (confirmCallback) {
        confirmCallback();
    }
    closeConfirm();
}

// CRUD Actions (Mock)
function deleteItem(type, id) {
    showConfirm('Hapus Item', 'Apakah Anda yakin ingin menghapus item ini?', () => {
        alert(`${type} dengan ID ${id} berhasil dihapus (Mock)`);
        location.reload();
    });
}

function approveItem(type, id) {
    showConfirm('Approve Item', 'Apakah Anda yakin ingin menyetujui item ini?', () => {
        alert(`${type} dengan ID ${id} berhasil diapprove (Mock)`);
        location.reload();
    });
}

function rejectItem(type, id) {
    showConfirm('Reject Item', 'Apakah Anda yakin ingin menolak item ini?', () => {
        alert(`${type} dengan ID ${id} berhasil ditolak (Mock)`);
        location.reload();
    });
}

function toggleStatus(type, id) {
    alert(`Status ${type} dengan ID ${id} berhasil diubah (Mock)`);
}

// Form Submission (Mock)
function submitForm(formType) {
    alert(`Form ${formType} berhasil disimpan (Mock)`);
    history.back();
}

// Filter Chips
function setFilter(chip) {
    document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
    chip.classList.add('active');
    // In real app, would filter the data
}

// Stats Counter Animation
function animateValue(element, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        element.innerText = Math.floor(progress * (end - start) + start).toLocaleString('id-ID');
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}
