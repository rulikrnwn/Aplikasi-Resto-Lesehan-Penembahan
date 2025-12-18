<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    use HasFactory;

    protected $table = 'pesanan';
    protected $primaryKey = 'id_pesanan';
    public $incrementing = true;
    public $timestamps = false;

    protected $fillable = [
        'id_sewa',
        'id_pengguna',
        'tanggal',
        'total',
        'bukti'
    ];

    public function ruangan()
    {
        return $this->belongsTo(Ruangan::class, 'id_sewa', 'id_ruangan');
        
    }
}
