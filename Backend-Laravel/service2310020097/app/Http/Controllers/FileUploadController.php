<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FileUploadController extends Controller
{
    public function uploadBukti(Request $request)
    {
        $request->validate([
            'bukti' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120', // Max 5MB
        ]);

        try {
            if ($request->hasFile('bukti')) {
                $file = $request->file('bukti');

                // Generate nama file unik
                $fileName = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();

                // Simpan file ke storage
                $path = $file->storeAs('public/bukti_pembayaran', $fileName);

                // Kembalikan nama file (tanpa path)
                return response()->json([
                    'success' => true,
                    'filename' => $fileName,
                    'message' => 'File berhasil diupload'
                ], 200);
            }

            return response()->json([
                'success' => false,
                'message' => 'Tidak ada file yang diupload'
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupload file: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getBukti($filename)
    {
        try {
            $path = storage_path('app/public/bukti_pembayaran/' . $filename);

            if (!file_exists($path)) {
                return response()->json([
                    'success' => false,
                    'message' => 'File tidak ditemukan'
                ], 404);
            }

            return response()->file($path);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil file'
            ], 500);
        }
    }
}
