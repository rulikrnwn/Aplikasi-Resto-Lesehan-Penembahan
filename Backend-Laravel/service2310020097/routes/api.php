<?php

use App\Http\Controllers\PesananController;
use App\Http\Controllers\RuanganController;
use App\Http\Controllers\FileUploadController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::apiResource('ruangan', RuanganController::class);
Route::apiResource('pesanan', PesananController::class);

// Route khusus upload file
Route::post('/upload-bukti', [FileUploadController::class, 'uploadBukti']);
Route::get('/bukti/{filename}', [FileUploadController::class, 'getBukti']);

// Route khusus relasi
Route::get('ruangan/{id}/pesanan', [RuanganController::class, 'getPesananByRuangan']);
Route::get('pesanan-with-ruangan', [PesananController::class, 'getPesananWithRuangan']);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
