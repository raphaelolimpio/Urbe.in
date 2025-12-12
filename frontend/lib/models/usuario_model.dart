class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String tipoUsuario;
  final String? senha; 
  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    this.senha,
  });


  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipoUsuario: json['tipo_usuario'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'tipo_usuario': tipoUsuario,
      if (senha != null) 'senha': senha,
    };
  }
}