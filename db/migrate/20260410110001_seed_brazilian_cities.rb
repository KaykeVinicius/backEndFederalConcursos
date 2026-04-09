class SeedBrazilianCities < ActiveRecord::Migration[8.0]
  def up
    # Fonte: IBGE — municípios brasileiros organizados por estado (UF)
    cities = [
      # Acre
      ["Acrelândia","AC"],["Assis Brasil","AC"],["Brasiléia","AC"],["Bujari","AC"],["Capixaba","AC"],
      ["Cruzeiro do Sul","AC"],["Epitaciolândia","AC"],["Feijó","AC"],["Jordão","AC"],["Mâncio Lima","AC"],
      ["Manoel Urbano","AC"],["Marechal Thaumaturgo","AC"],["Plácido de Castro","AC"],["Porto Acre","AC"],
      ["Porto Walter","AC"],["Rio Branco","AC"],["Rodrigues Alves","AC"],["Santa Rosa do Purus","AC"],
      ["Sena Madureira","AC"],["Senador Guiomard","AC"],["Tarauacá","AC"],["Xapuri","AC"],

      # Alagoas
      ["Água Branca","AL"],["Anadia","AL"],["Arapiraca","AL"],["Atalaia","AL"],["Barra de Santo Antônio","AL"],
      ["Barra de São Miguel","AL"],["Batalha","AL"],["Belém","AL"],["Belo Monte","AL"],["Boca da Mata","AL"],
      ["Branquinha","AL"],["Cacimbinhas","AL"],["Cajueiro","AL"],["Campestre","AL"],["Campo Alegre","AL"],
      ["Campo Grande","AL"],["Canapi","AL"],["Capela","AL"],["Carneiros","AL"],["Chã Preta","AL"],
      ["Coité do Nóia","AL"],["Colônia Leopoldina","AL"],["Coqueiro Seco","AL"],["Coruripe","AL"],
      ["Craíbas","AL"],["Delmiro Gouveia","AL"],["Dois Riachos","AL"],["Estrela de Alagoas","AL"],
      ["Feira Grande","AL"],["Feliz Deserto","AL"],["Flexeiras","AL"],["Girau do Ponciano","AL"],
      ["Ibateguara","AL"],["Igaci","AL"],["Igreja Nova","AL"],["Inhapi","AL"],["Jacaré dos Homens","AL"],
      ["Jacuípe","AL"],["Japaratinga","AL"],["Jaramataia","AL"],["Jequiá da Praia","AL"],["Joaquim Gomes","AL"],
      ["Jundiá","AL"],["Junqueiro","AL"],["Lagoa da Canoa","AL"],["Limoeiro de Anadia","AL"],
      ["Maceió","AL"],["Major Isidoro","AL"],["Mar Vermelho","AL"],["Maragogi","AL"],["Maravilha","AL"],
      ["Marechal Deodoro","AL"],["Maribondo","AL"],["Mata Grande","AL"],["Matriz de Camaragibe","AL"],
      ["Messias","AL"],["Minador do Negrão","AL"],["Monteirópolis","AL"],["Murici","AL"],
      ["Novo Lino","AL"],["Olho d'Água das Flores","AL"],["Olho d'Água do Casado","AL"],
      ["Olho d'Água Grande","AL"],["Olivença","AL"],["Ouro Branco","AL"],["Palestina","AL"],
      ["Palmeira dos Índios","AL"],["Pão de Açúcar","AL"],["Pariconha","AL"],["Paripueira","AL"],
      ["Passo de Camaragibe","AL"],["Paulo Jacinto","AL"],["Penedo","AL"],["Piaçabuçu","AL"],
      ["Pilar","AL"],["Pindoba","AL"],["Piranhas","AL"],["Poço das Trincheiras","AL"],
      ["Porto Calvo","AL"],["Porto de Pedras","AL"],["Porto Real do Colégio","AL"],["Quebrangulo","AL"],
      ["Rio Largo","AL"],["Roteiro","AL"],["Santa Luzia do Norte","AL"],["Santana do Ipanema","AL"],
      ["Santana do Mundaú","AL"],["São Brás","AL"],["São José da Laje","AL"],["São José da Tapera","AL"],
      ["São Luís do Quitunde","AL"],["São Miguel dos Campos","AL"],["São Miguel dos Milagres","AL"],
      ["São Sebastião","AL"],["Satuba","AL"],["Senador Rui Palmeira","AL"],["Tanque d'Arca","AL"],
      ["Taquarana","AL"],["Teotônio Vilela","AL"],["Traipu","AL"],["União dos Palmares","AL"],
      ["Viçosa","AL"],

      # Amapá
      ["Amapá","AP"],["Calçoene","AP"],["Cutias","AP"],["Ferreira Gomes","AP"],["Itaubal","AP"],
      ["Laranjal do Jari","AP"],["Macapá","AP"],["Mazagão","AP"],["Oiapoque","AP"],["Pedra Branca do Amapari","AP"],
      ["Porto Grande","AP"],["Pracuúba","AP"],["Santana","AP"],["Serra do Navio","AP"],
      ["Tartarugalzinho","AP"],["Vitória do Jari","AP"],

      # Amazonas
      ["Alvarães","AM"],["Amaturá","AM"],["Anamã","AM"],["Anori","AM"],["Apuí","AM"],
      ["Atalaia do Norte","AM"],["Autazes","AM"],["Barcelos","AM"],["Barreirinha","AM"],
      ["Benjamin Constant","AM"],["Beruri","AM"],["Boa Vista do Ramos","AM"],["Boca do Acre","AM"],
      ["Borba","AM"],["Caapiranga","AM"],["Canutama","AM"],["Carauari","AM"],["Careiro","AM"],
      ["Careiro da Várzea","AM"],["Coari","AM"],["Codajás","AM"],["Eirunepé","AM"],["Envira","AM"],
      ["Fonte Boa","AM"],["Guajará","AM"],["Humaitá","AM"],["Ipixuna","AM"],["Iranduba","AM"],
      ["Itacoatiara","AM"],["Itamarati","AM"],["Itapiranga","AM"],["Japurá","AM"],["Juruá","AM"],
      ["Jutaí","AM"],["Lábrea","AM"],["Manacapuru","AM"],["Manaquiri","AM"],["Manaus","AM"],
      ["Manicoré","AM"],["Maraã","AM"],["Maués","AM"],["Nhamundá","AM"],["Nova Olinda do Norte","AM"],
      ["Novo Airão","AM"],["Novo Aripuanã","AM"],["Parintins","AM"],["Pauini","AM"],
      ["Presidente Figueiredo","AM"],["Rio Preto da Eva","AM"],["Santa Isabel do Rio Negro","AM"],
      ["Santo Antônio do Içá","AM"],["São Gabriel da Cachoeira","AM"],["São Paulo de Olivença","AM"],
      ["São Sebastião do Uatumã","AM"],["Silves","AM"],["Tabatinga","AM"],["Tapauá","AM"],
      ["Tefé","AM"],["Tonantins","AM"],["Uarini","AM"],["Urucará","AM"],["Urucurituba","AM"],

      # Bahia (principais)
      ["Alagoinhas","BA"],["Barreiras","BA"],["Camaçari","BA"],["Caravelas","BA"],["Cruz das Almas","BA"],
      ["Eunápolis","BA"],["Feira de Santana","BA"],["Guanambi","BA"],["Ilhéus","BA"],["Itabuna","BA"],
      ["Itamaraju","BA"],["Jequié","BA"],["Juazeiro","BA"],["Lauro de Freitas","BA"],["Luís Eduardo Magalhães","BA"],
      ["Paulo Afonso","BA"],["Porto Seguro","BA"],["Ribeira do Pombal","BA"],["Salvador","BA"],
      ["Santo Antônio de Jesus","BA"],["Teixeira de Freitas","BA"],["Valença","BA"],["Vitória da Conquista","BA"],

      # Ceará (principais)
      ["Barbalha","CE"],["Caucaia","CE"],["Crato","CE"],["Fortaleza","CE"],["Iguatu","CE"],
      ["Itapipoca","CE"],["Juazeiro do Norte","CE"],["Maracanaú","CE"],["Maranguape","CE"],
      ["Pacatuba","CE"],["Quixadá","CE"],["Russas","CE"],["Sobral","CE"],

      # Distrito Federal
      ["Brasília","DF"],

      # Espírito Santo (principais)
      ["Aracruz","ES"],["Cachoeiro de Itapemirim","ES"],["Cariacica","ES"],["Colatina","ES"],
      ["Guarapari","ES"],["Linhares","ES"],["São Mateus","ES"],["Serra","ES"],["Viana","ES"],
      ["Vila Velha","ES"],["Vitória","ES"],

      # Goiás (principais)
      ["Águas Lindas de Goiás","GO"],["Anápolis","GO"],["Aparecida de Goiânia","GO"],["Caldas Novas","GO"],
      ["Catalão","GO"],["Formosa","GO"],["Goiânia","GO"],["Itumbiara","GO"],["Luziânia","GO"],
      ["Rio Verde","GO"],["Trindade","GO"],["Valparaíso de Goiás","GO"],

      # Maranhão (principais)
      ["Açailândia","MA"],["Bacabal","MA"],["Balsas","MA"],["Caxias","MA"],["Codó","MA"],
      ["Imperatriz","MA"],["Paço do Lumiar","MA"],["São José de Ribamar","MA"],["São Luís","MA"],
      ["Timon","MA"],

      # Mato Grosso (principais)
      ["Alta Floresta","MT"],["Cáceres","MT"],["Cuiabá","MT"],["Lucas do Rio Verde","MT"],
      ["Rondonópolis","MT"],["Sinop","MT"],["Tangará da Serra","MT"],["Várzea Grande","MT"],

      # Mato Grosso do Sul (principais)
      ["Campo Grande","MS"],["Corumbá","MS"],["Dourados","MS"],["Naviraí","MS"],["Ponta Porã","MS"],
      ["Três Lagoas","MS"],

      # Minas Gerais (principais)
      ["Araguari","MG"],["Betim","MG"],["Belo Horizonte","MG"],["Contagem","MG"],["Divinópolis","MG"],
      ["Governador Valadares","MG"],["Ipatinga","MG"],["Juiz de Fora","MG"],["Montes Claros","MG"],
      ["Patos de Minas","MG"],["Poços de Caldas","MG"],["Pouso Alegre","MG"],["Ribeirão das Neves","MG"],
      ["Santa Luzia","MG"],["Sete Lagoas","MG"],["Uberaba","MG"],["Uberlândia","MG"],
      ["Varginha","MG"],

      # Pará (principais)
      ["Abaetetuba","PA"],["Altamira","PA"],["Ananindeua","PA"],["Belém","PA"],["Castanhal","PA"],
      ["Itaituba","PA"],["Marabá","PA"],["Parauapebas","PA"],["Redenção","PA"],["Santarém","PA"],
      ["Tucuruí","PA"],

      # Paraíba (principais)
      ["Bayeux","PB"],["Cabedelo","PB"],["Cajazeiras","PB"],["Campina Grande","PB"],["João Pessoa","PB"],
      ["Patos","PB"],["Santa Rita","PB"],["Sousa","PB"],

      # Paraná (principais)
      ["Apucarana","PR"],["Araucária","PR"],["Cascavel","PR"],["Colombo","PR"],["Curitiba","PR"],
      ["Foz do Iguaçu","PR"],["Guarapuava","PR"],["Londrina","PR"],["Maringá","PR"],
      ["Paranaguá","PR"],["Pinhais","PR"],["Ponta Grossa","PR"],["São José dos Pinhais","PR"],
      ["Umuarama","PR"],

      # Pernambuco (principais)
      ["Caruaru","PE"],["Garanhuns","PE"],["Jaboatão dos Guararapes","PE"],["Olinda","PE"],
      ["Paulista","PE"],["Petrolina","PE"],["Recife","PE"],["Santa Cruz do Capibaribe","PE"],

      # Piauí (principais)
      ["Parnaíba","PI"],["Picos","PI"],["Teresina","PI"],

      # Rio de Janeiro (principais)
      ["Belford Roxo","RJ"],["Campos dos Goytacazes","RJ"],["Duque de Caxias","RJ"],["Itaboraí","RJ"],
      ["Macaé","RJ"],["Niterói","RJ"],["Nova Friburgo","RJ"],["Nova Iguaçu","RJ"],["Petrópolis","RJ"],
      ["Rio de Janeiro","RJ"],["São Gonçalo","RJ"],["São João de Meriti","RJ"],["Volta Redonda","RJ"],

      # Rio Grande do Norte (principais)
      ["Caicó","RN"],["Mossoró","RN"],["Natal","RN"],["Parnamirim","RN"],["Santa Cruz","RN"],

      # Rio Grande do Sul (principais)
      ["Alvorada","RS"],["Cachoeirinha","RS"],["Canoas","RS"],["Caxias do Sul","RS"],["Gravataí","RS"],
      ["Novo Hamburgo","RS"],["Passo Fundo","RS"],["Pelotas","RS"],["Porto Alegre","RS"],
      ["Santa Maria","RS"],["São Leopoldo","RS"],["Viamão","RS"],

      # Rondônia — todos os municípios
      ["Alta Floresta d'Oeste","RO"],["Alto Alegre dos Parecis","RO"],["Alto Paraíso","RO"],
      ["Alvorada d'Oeste","RO"],["Ariquemes","RO"],["Buritis","RO"],["Cabixi","RO"],
      ["Cacaulândia","RO"],["Cacoal","RO"],["Campo Novo de Rondônia","RO"],["Candeias do Jamari","RO"],
      ["Castanheiras","RO"],["Cerejeiras","RO"],["Chupinguaia","RO"],["Colorado do Oeste","RO"],
      ["Corumbiara","RO"],["Costa Marques","RO"],["Cujubim","RO"],["Espigão d'Oeste","RO"],
      ["Governador Jorge Teixeira","RO"],["Guajará-Mirim","RO"],["Itapuã do Oeste","RO"],
      ["Jaru","RO"],["Ji-Paraná","RO"],["Machadinho d'Oeste","RO"],["Ministro Andreazza","RO"],
      ["Mirante da Serra","RO"],["Monte Negro","RO"],["Nova Brasilândia d'Oeste","RO"],
      ["Nova Mamoré","RO"],["Nova União","RO"],["Novo Horizonte do Oeste","RO"],
      ["Ouro Preto do Oeste","RO"],["Parecis","RO"],["Pimenta Bueno","RO"],
      ["Pimenteiras do Oeste","RO"],["Porto Velho","RO"],["Presidente Médici","RO"],
      ["Primavera de Rondônia","RO"],["Rio Crespo","RO"],["Rolim de Moura","RO"],
      ["Santa Luzia d'Oeste","RO"],["São Felipe d'Oeste","RO"],["São Francisco do Guaporé","RO"],
      ["São Miguel do Guaporé","RO"],["Seringueiras","RO"],["Teixeirópolis","RO"],
      ["Theobroma","RO"],["Urupá","RO"],["Vale do Anari","RO"],["Vale do Paraíso","RO"],
      ["Vilhena","RO"],

      # Roraima
      ["Alto Alegre","RR"],["Amajari","RR"],["Boa Vista","RR"],["Bonfim","RR"],["Cantá","RR"],
      ["Caroebe","RR"],["Iracema","RR"],["Mucajaí","RR"],["Normandia","RR"],["Pacaraima","RR"],
      ["Rorainópolis","RR"],["São João da Baliza","RR"],["São Luiz","RR"],["Uiramutã","RR"],

      # Santa Catarina (principais)
      ["Balneário Camboriú","SC"],["Blumenau","SC"],["Chapecó","SC"],["Criciúma","SC"],
      ["Florianópolis","SC"],["Itajaí","SC"],["Jaraguá do Sul","SC"],["Joinville","SC"],
      ["Lages","SC"],["Palhoça","SC"],["São José","SC"],

      # São Paulo (principais)
      ["Barueri","SP"],["Bauru","SP"],["Campinas","SP"],["Diadema","SP"],["Franca","SP"],
      ["Guarulhos","SP"],["Jundiaí","SP"],["Limeira","SP"],["Mauá","SP"],["Mogi das Cruzes","SP"],
      ["Osasco","SP"],["Piracicaba","SP"],["Presidente Prudente","SP"],["Ribeirão Preto","SP"],
      ["Santo André","SP"],["Santos","SP"],["São Bernardo do Campo","SP"],["São Caetano do Sul","SP"],
      ["São José do Rio Preto","SP"],["São José dos Campos","SP"],["São Paulo","SP"],
      ["Sorocaba","SP"],["Taubaté","SP"],

      # Sergipe (principais)
      ["Aracaju","SE"],["Itabaiana","SE"],["Lagarto","SE"],["Nossa Senhora do Socorro","SE"],
      ["São Cristóvão","SE"],

      # Tocantins (principais)
      ["Araguaína","TO"],["Gurupi","TO"],["Palmas","TO"],["Porto Nacional","TO"],
    ]

    cities.each do |name, state|
      City.find_or_create_by!(name: name, state: state)
    rescue ActiveRecord::RecordInvalid => e
      # ignora duplicatas se já existirem
      Rails.logger.warn "Cidade ignorada (#{name}/#{state}): #{e.message}"
    end
  end

  def down
    # Não apaga cidades que já possam ter alunos vinculados
  end
end
