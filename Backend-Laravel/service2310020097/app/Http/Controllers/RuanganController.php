<?php

namespace App\Http\Controllers;

use App\Models\Ruangan;
use Illuminate\Http\Request;

class RuanganController extends Controller
{
    public function index()
    {
        return Ruangan::with('pesanan')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string',
            'status' => 'required|string',
            'harga' => 'required|string',
        ]);
        return Ruangan::create($request->all());
    }

    public function show(string $id)
    {
        return Ruangan::with('pesanan')->findOrFail($id);
    }

    public function update(Request $request, string $id)
    {
        $ruangan = Ruangan::findOrFail($id);
        $request->validate([
            'nama' => 'sometimes|required|string',
            'status' => 'sometimes|required|string',
            'harga' => 'sometimes|required|string',
        ]);
        $ruangan->update($request->all());
        return $ruangan;
    }

    public function destroy(string $id)
    {
        $ruangan = Ruangan::findOrFail($id);
        $ruangan->delete();
        return response()->noContent();
    }

    // Di RuanganController
    public function getPesananByRuangan(string $id)
    {
        $ruangan = Ruangan::with('pesanan')->findOrFail($id);
        return response()->json([
            'ruangan' => $ruangan->nama,
            'total_pesanan' => $ruangan->pesanan->count(),
            'data_pesanan' => $ruangan->pesanan
        ]);
    }
}
