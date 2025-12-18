<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pesanan', function (Blueprint $table) {
            $table->id('id_pesanan');
            $table->unsignedBigInteger('id_sewa'); // Ganti jadi unsignedBigInteger
            $table->string('id_pengguna');
            $table->string('tanggal');
            $table->string('total');
            $table->string('bukti');

            // ✅ TAMBAHKAN FOREIGN KEY
            $table->foreign('id_sewa')
                ->references('id_ruangan')
                ->on('ruangan')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pesanan');
    }
};
