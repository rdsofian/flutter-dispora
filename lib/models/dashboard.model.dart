class DashboardModel {
  
  final int idDesa;
  final String namaDesa;
  final String namaKecamatan;
  final String foto;

  DashboardModel({
    required this.idDesa,
    required this.namaDesa,
    required this.namaKecamatan,
    required this.foto
  });

  static DashboardModel fromJson(Map<String, dynamic> json) => DashboardModel(
    idDesa: json['id_desa'], 
    namaDesa: json['nama_desa'], 
    namaKecamatan: json['nama_kecamatan'], 
    foto: json['foto']);
}
