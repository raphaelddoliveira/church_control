import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'home_page_admin_model.dart';
export 'home_page_admin_model.dart';

class HomePageAdminWidget extends StatefulWidget {
  const HomePageAdminWidget({super.key});

  static String routeName = 'HomePage_Admin';
  static String routePath = '/HomePage_Admin';

  @override
  State<HomePageAdminWidget> createState() => _HomePageAdminWidgetState();
}

class _HomePageAdminWidgetState extends State<HomePageAdminWidget> {
  late HomePageAdminModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _totalNiveisAcesso = 0;
  int _totalMinisterios = 0;
  int _totalMembros = 0;
  List<VwCriacoesMesAtualRow> _atividadesRecentes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageAdminModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final niveisRows = await NiveisAcessoTable().queryRows(
        queryFn: (q) => q,
      );

      final ministerioRows = await MinisterioTable().queryRows(
        queryFn: (q) => q,
      );

      final membrosRows = await MembrosTable().queryRows(
        queryFn: (q) => q,
      );

      final atividadesRows = await VwCriacoesMesAtualTable().queryRows(
        queryFn: (q) => q.order('data'),
        limit: 8,
      );

      setState(() {
        _totalNiveisAcesso = niveisRows.length;
        _totalMinisterios = ministerioRows.length;
        _totalMembros = membrosRows.length;
        _atividadesRecentes = atividadesRows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
            children: [
              // Menu lateral
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
                child: Container(
                  width: 250.0,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    color: Color(0xFF3C3D3E),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: wrapWithModel(
                    model: _model.menuAdminModel,
                    updateCallback: () => setState(() {}),
                    child: MenuAdminWidget(),
                  ),
                ),
              ),

              // Conteudo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                _buildHeader(context),

                                SizedBox(height: 32.0),

                                // Indicadores
                                _buildSectionTitle('Indicadores Rapidos', Icons.analytics_rounded),
                                SizedBox(height: 16.0),
                                _buildIndicadores(context),

                                SizedBox(height: 32.0),

                                // Acoes Rapidas
                                _buildSectionTitle('Acoes Rapidas', Icons.flash_on_rounded),
                                SizedBox(height: 16.0),
                                _buildAcoesRapidas(context),

                                SizedBox(height: 32.0),

                                // Atividades Recentes
                                _buildSectionTitle('Atividades Recentes', Icons.history_rounded),
                                SizedBox(height: 16.0),
                                _buildAtividadesRecentes(context),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem Vindo,',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'PIB Santa Fe do Sul',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'Administrador',
                style: GoogleFonts.inter(
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 18.0,
          ),
        ),
        SizedBox(width: 12.0),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicadores(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.tune_rounded,
            title: 'Niveis de Acesso',
            value: _totalNiveisAcesso.toString(),
            color: Color(0xFF39D2C0),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.church_rounded,
            title: 'Ministerios',
            value: _totalMinisterios.toString(),
            color: Color(0xFFEE8B60),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.group_rounded,
            title: 'Membros',
            value: _totalMembros.toString(),
            color: Color(0xFFF9CF58),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.0,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoesRapidas(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.add_circle_rounded,
            title: 'Criar Novo Ministerio',
            subtitle: 'Adicionar um novo ministerio',
            color: Color(0xFF4B39EF),
            onTap: () async {
              final result = await showDialog(
                context: context,
                builder: (dialogContext) {
                  return Dialog(
                    elevation: 0,
                    insetPadding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    child: PageMinisterioAdminNovoWidget(),
                  );
                },
              );
              if (result == true) _carregarDados();
            },
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.people_rounded,
            title: 'Gerenciar Membros',
            subtitle: 'Ver todos os membros',
            color: Color(0xFF39D2C0),
            onTap: () {
              context.pushNamed(PageMembrosAdminWidget.routeName);
            },
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.church_rounded,
            title: 'Ver Ministerios',
            subtitle: 'Listar todos os ministerios',
            color: Color(0xFFEE8B60),
            onTap: () {
              context.pushNamed(PageMinisteriosAdminWidget.routeName);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.0,
              ),
            ),
            SizedBox(height: 14.0),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Color(0xFF888888),
                fontSize: 13.0,
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Text(
                  'Acessar',
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.0),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 16.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtividadesRecentes(BuildContext context) {
    if (_atividadesRecentes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                color: Color(0xFF555555),
                size: 48.0,
              ),
              SizedBox(height: 12.0),
              Text(
                'Nenhuma atividade recente',
                style: GoogleFonts.inter(
                  color: Color(0xFF888888),
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListView.separated(
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _atividadesRecentes.length,
        separatorBuilder: (_, __) => Divider(
          color: Color(0xFF3A3A3A),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final atividade = _atividadesRecentes[index];
          final isAlteracao = atividade.tipo == 'membro_alterado';

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: isAlteracao
                        ? Color(0xFFFF9800).withOpacity(0.15)
                        : Color(0xFF4B39EF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    isAlteracao ? Icons.edit_rounded : Icons.person_add_rounded,
                    color: isAlteracao ? Color(0xFFFF9800) : Color(0xFF4B39EF),
                    size: 20.0,
                  ),
                ),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isAlteracao ? 'Atualizacao Membro:' : 'Novo Registro:'} ${atividade.nome ?? ''}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        atividade.dataField != null
                            ? DateFormat('dd/MM/yyyy').format(atividade.dataField!)
                            : '',
                        style: GoogleFonts.inter(
                          color: Color(0xFF888888),
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isAlteracao
                        ? Color(0xFFFF9800).withOpacity(0.1)
                        : Color(0xFF4B39EF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    isAlteracao ? 'Alterado' : 'Novo',
                    style: GoogleFonts.inter(
                      color: isAlteracao ? Color(0xFFFF9800) : Color(0xFF4B39EF),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
