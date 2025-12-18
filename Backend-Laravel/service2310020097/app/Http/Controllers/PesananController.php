<?php

namespace App\Http\Controllers;

use App\Models\Pesanan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PesananController extends Controller
{
    public function index()
    {
        // Ambil semua pesanan dengan relasi ruangan
        return Pesanan::with('ruangan')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_sewa' => 'required|integer|exists:ruangan,id_ruangan',
            'id_pengguna' => 'required|string|max:100',
            'tanggal' => 'required|date',
            'total' => 'required|numeric',
            'bukti' => 'nullable|string', // Sekarang nullable karena diupload terpisah
        ]);

        try {
            $pesanan = Pesanan::create($request->all());

            return response()->json([
                'success' => true,
                'data' => $pesanan->load('ruangan'),
                'message' => 'Pesanan berhasil dibuat'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat pesanan: ' . $e->getMessage()
            ], 500);
        }
    }

    public function show(string $id)
    {
        try {
            $pesanan = Pesanan::with('ruangan')->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $pesanan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak ditemukan'
            ], 404);
        }
    }

    public function update(Request $request, string $id)
    {
        try {
            $pesanan = Pesanan::findOrFail($id);

            $request->validate([
                'id_sewa' => 'sometimes|required|integer|exists:ruangan,id_ruangan',
                'id_pengguna' => 'sometimes|required|string|max:100',
                'tanggal' => 'sometimes|required|date',
                'total' => 'sometimes|required|numeric',
                'bukti' => 'nullable|string',
            ]);

            $pesanan->update($request->all());

            return response()->json([
                'success' => true,
                'data' => $pesanan->load('ruangan'),
                'message' => 'Pesanan berhasil diperbarui'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui pesanan: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroy(string $id)
    {
        try {
            $pesanan = Pesanan::findOrFail($id);

            // Hapus file bukti jika ada
            if ($pesanan->bukti) {
                Storage::delete('public/bukti_pembayaran/' . $pesanan->bukti);
            }

            $pesanan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus pesanan: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getPesananWithRuangan()
    {
        try {
            $pesanan = Pesanan::with(['ruangan:id_ruangan,nama,status,harga'])
                ->select('id_pesanan', 'id_sewa', 'id_pengguna', 'tanggal', 'total', 'bukti')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $pesanan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data'
            ], 500);
        }
    }
}
