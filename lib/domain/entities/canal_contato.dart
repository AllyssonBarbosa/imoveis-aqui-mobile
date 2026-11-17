/// Canal pelo qual o visitante pode falar com o responsável pelo imóvel.
///
/// A ordem da declaração é a prioridade fixa do botão principal (D-06):
/// WhatsApp, depois telefone, depois e-mail. O app nunca deduz canais — eles
/// vêm do `canais_contato` calculado pelo servidor; os nomes do wire moram só
/// em `data/` (`CanalContatoNaApi`).
enum CanalContato { whatsapp, telefone, email }
