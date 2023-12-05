# Aws_Nuvem

Adendo do word enviado

Execução:

Deve-se configurar as credenciais da AWS via AWS CLI. Com isso 
feito se não existir um bucket S3 chamado “pedropmc-bucket” é necessário cria-lo na 
mão. Isso é essencial não deixe de criar o bucket com o exato nome. É essencial que esse seja o nome, pois está hardcodado na API e no terraform. Então como só pode criar um bucket S3 com o mesmo nome global, peço que caso os testes entre os professores sejam feitos em contas diferentes é recomendado que eles não sejam feitos ao mesmo tempo por não poder criar dois buckets iguais. Há duas maneiras de contornar isso:

1. Cada professor testar e depois apagar o bucket, para evitar falha na criação.

2. Forkar o repo da API mudar o nome do bucket para o desejado que está na linha 16 em app/main.py. Trocar o repositório passado no projeto de cloud em user_data em modules/ec2/ec2.tf para o forkado e alterar a linha 11 do main.tf com o nome do bucket desejado.

A aplicação ainda vai funcionar indpendente se você criar o bucket com o nome certo ou não, contudo, não será possível ver os Logs e deverá ser alterado no main.tf.
