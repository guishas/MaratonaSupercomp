# MaratonaSupercomp

Você quer passar um final de semana assistindo ao máximo de filmes possível, mas há restrições quanto aos horários disponíveis e ao número de títulos que podem ser vistos em cada categoria (comédia, drama, ação, etc).

Entrada: Um inteiro N representando o número de filmes disponíveis para assistir e N trios de inteiros (H[i], F[i], C[i]), representando a hora de início, a hora de fim e a categoria do i-ésimo filme. Além disso, um inteiro M representando o número de categorias e uma lista de M inteiros representando o número máximo de filmes que podem ser assistidos em cada categoria.

Saída: Um inteiro representando o número máximo de filmes que podem ser assistidos de acordo com as restrições de horários e número máximo por categoria.

## Heurística Gulosa

A primeira implementação da heurística para nosso projeto consiste em uma implementação gulosa (Greedy).

Implemente uma versão gulosa que ordena os filmes por hora de fim crescente e escolhe aqueles que começam primeiro e não conflitam com os filmes já escolhidos, além de verificar se há vagas disponíveis na categoria do filme.

## Aleatoriedade

Como vimos em aula, aleatoriedade é uma estratégia bastante comum para construção de algoritmos de busca local, podendo ser usada de forma isolada ou de forma complementar a outra estratégia de varredura de um espaço de soluções.

Essa implementação consiste na adaptação da heurística gulosa de nosso projeto. A proposta é que você modifique a sua heurística gulosa de modo que ao longo da seleção de um filme você tenha 25% de chance de pegar outro filme qualquer que respeite o horário. Isso fará com que sua heurística tenha um pouco mais de exploration e possamos ter alguns resultados melhores.

Importante: é essencial que você guarde todos os inputs usados ao longo do projeto, para que possa comparar o desempenho de seus algoritmos conforme mudamos a heurística. Ou seja, todas as heurísticas devem ser submetidas aos mesmos arquivos de input. O seu resultado deve ser comparado sob duas perspectivas, no mínimo: (i) tempo de execução em função do aumento de filmes e de categorias e (ii) tempo de tela (isto é, será que estamos conseguindo ocupar bem as 24h do dia assitindo filmes?).

## Relatório Parcial

O relatório parcial é a entrega intermediária do projeto, a qual deve ser feita pelo blackboard até a data da prova intermediária.

Seu relatório deverá conter as implementações gulosa e aleatória.

O que você deverá fazer:

No blackboard, você deve fazer upload de todos os códigos-fonte, arquivos de input, arquivos de output para cada heurítica. Caso opte por enviar um link do github com o repositório completo, também poderá faze-lo, desde que garanta que teremos acesso aos arquivos no seu repositório;

Você deve elaborar um relatório parcial contendo as seguintes seções:

Para cada heurística você deve explicar como implementou a heurística (detalhe como você tratou o input, qual a lógica do seu output, quais invariantes existem em suas heurísticas), apresentar (i) o código-fonte comentado, (ii) fazer considerações sobre o profiling (valgrind) do código-fonte (use apenas 1 arquivo de input para isso, não há necessidade de fazer esse profiling para vários inputs), (iii) o resultado compartivo entre as heurísticas quando você varia o input (o input deve variar na quantidade de filmes e de categorias).

Seu relatório deve ser gráficos e tabelas que subsidem as suas considerações

É permitido criar um programa em python ou outra linguagem que automatize a geração de seus resultados, isto é, que execute seus códigos C++ em função dos diferentes inputs.

Preferencialmente o relatório deve ser apresentado em formato html.

## Desenvolvido por
* Guilherme Lunetta
