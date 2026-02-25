-- Criar tabela de indisponibilidade de membros para escalas
-- Execute este SQL no Supabase SQL Editor

CREATE TABLE membro_indisponibilidade (
  id BIGSERIAL PRIMARY KEY,
  id_membro TEXT NOT NULL,
  data_inicio DATE NOT NULL,
  data_fim DATE NOT NULL,
  motivo TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Criar index para buscas por membro
CREATE INDEX idx_membro_indisponibilidade_membro ON membro_indisponibilidade(id_membro);

-- Criar index para buscas por data
CREATE INDEX idx_membro_indisponibilidade_datas ON membro_indisponibilidade(data_inicio, data_fim);

-- Habilitar RLS
ALTER TABLE membro_indisponibilidade ENABLE ROW LEVEL SECURITY;

-- Politica: membros autenticados podem ler e escrever
CREATE POLICY "Authenticated users can read membro_indisponibilidade"
  ON membro_indisponibilidade FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert membro_indisponibilidade"
  ON membro_indisponibilidade FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete membro_indisponibilidade"
  ON membro_indisponibilidade FOR DELETE
  TO authenticated
  USING (true);
