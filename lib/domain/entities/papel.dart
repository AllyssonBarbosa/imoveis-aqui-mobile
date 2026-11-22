/// Papel do usuário logado no app. Vem sempre do servidor (`GET
/// /api/auth/eu/`): o app nunca infere o papel nem decide permissão — só
/// escolhe qual área mostrar (D-02).
enum Papel { corretor, gestor, administrador }
