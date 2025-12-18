<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Ruangan extends Model
{
    protected $table = 'ruangan';
    protected $primaryKey = 'id_ruangan';
    public $incrementing = true;
    public $timestamps = false;  
    protected $fillable = ['nama', 'status', 'harga'];

    public function pesanan()
    {
        return $this->hasMany(Pesanan::class, 'id_sewa', 'id_ruangan');

    }
}
