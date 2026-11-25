import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/papel.dart';
import '../acervo/acervo_screen.dart';
import '../area_gestor/area_gestor_screen.dart';
import '../sessao/aviso_area_screen.dart';
import '../sessao/sessao_cubit.dart';
import 'login_cubit.dart';
import 'login_state.dart';

/// Tela de login do corretor (AUTH-01). A tela só valida campo vazio e envia:
/// formato de e-mail e credencial são do servidor (D-01), e toda mensagem de
/// falha vem pronta do [LoginCubit] — nunca o texto do servidor (D-03).
///
/// Depois de entrar, a rota do login é substituída pela área do papel (D-02,
/// D-B): o corretor vai ao acervo, o gestor à Área do gestor (APP-12, D-01) e o
/// administrador ao aviso (D-02). O "voltar" nunca devolve o usuário ao login.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.aviso, this.criarCubit});

  /// Aviso opcional no topo, por exemplo "Sua sessão terminou. Entre de novo.".
  final String? aviso;

  /// Cria o Cubit da tela; `null` usa o localizador de serviços. Existe para
  /// os testes de widget não dependerem do DI.
  final LoginCubit Function()? criarCubit;

  @override
  Widget build(BuildContext context) {
    final criar = criarCubit ?? () => getIt<LoginCubit>();
    return BlocProvider<LoginCubit>(
      create: (_) => criar(),
      child: _CorpoLogin(aviso: aviso),
    );
  }
}

/// `StatefulWidget` só para hospedar o formulário, os controladores de texto e
/// o "mostrar senha" (estado efêmero de interface).
class _CorpoLogin extends StatefulWidget {
  const _CorpoLogin({this.aviso});

  final String? aviso;

  @override
  State<_CorpoLogin> createState() => _CorpoLoginState();
}

class _CorpoLoginState extends State<_CorpoLogin> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _controleEmail = TextEditingController();
  final TextEditingController _controleSenha = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _controleEmail.dispose();
    _controleSenha.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().entrar(
      email: _controleEmail.text.trim(),
      senha: _controleSenha.text,
    );
  }

  /// Marca a sessão e troca a rota do login pela área do [papel].
  void _aoEntrar(Papel papel) {
    TextInput.finishAutofillContext();
    context.read<SessaoCubit>().marcarAutenticada();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => switch (papel) {
          Papel.corretor => const AcervoScreen(),
          Papel.gestor => const AreaGestorScreen(),
          Papel.administrador => const AvisoAreaScreen(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aviso = widget.aviso;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (anterior, atual) => atual is LoginEntrou,
        listener: (context, state) {
          if (state is LoginEntrou) _aoEntrar(state.papel);
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formulario,
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (aviso != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: tema.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              aviso,
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _controleEmail,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) => (valor ?? '').trim().isEmpty
                            ? 'Informe o e-mail.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controleSenha,
                        obscureText: !_senhaVisivel,
                        autofillHints: const [AutofillHints.password],
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _senhaVisivel
                                ? 'Ocultar senha'
                                : 'Mostrar senha',
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (valor) =>
                            (valor ?? '').isEmpty ? 'Informe a senha.' : null,
                        onFieldSubmitted: (_) => _enviar(),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final enviando = state is LoginEnviando;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state case LoginFalha(:final mensagem)) ...[
                                Text(
                                  mensagem,
                                  style: tema.textTheme.bodyMedium?.copyWith(
                                    color: tema.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              FilledButton(
                                onPressed: enviando ? null : _enviar,
                                child: enviando
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Entrar'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
