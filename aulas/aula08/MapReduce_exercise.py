from mrjob.job import MRJob
from mrjob.step import MRStep
""" Se for necessario instalar o mrjob,
    pode ser feito atraves do comando:
    pip install mrjob==0.7.4   (na sandbox já está instalado)
"""

class RatingsBreakdown(MRJob):
    def steps(self):
        return [
                MRStep( mapper=self.mapper_get_ratings,
                        reducer=self.reducer_count_ratings)
                ]

    """ Mapper: Retorna uma tupla contendo a avaliacao e o numero 1 """
    def mapper_get_ratings(self, _, line):
        (userID, movieID, rating, timestamp) = line.split('\t')
        yield rating, 1

    """ Reducer: Soma os resultados """
    def reducer_count_ratings(self, key, values):
        yield key, sum(values)

if __name__ == '__main__':
    RatingsBreakdown.run()
