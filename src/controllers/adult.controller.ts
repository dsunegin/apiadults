import {
  Count,
  CountSchema,
  Filter,
  FilterExcludingWhere,
  repository,
  Where,
} from '@loopback/repository';
import {
  post,
  param,
  get,
  getModelSchemaRef,
  patch,
  put,
  del,
  requestBody,
  response,
} from '@loopback/rest';
import {Adult} from '../models';
import {AdultRepository} from '../repositories';

export class AdultController {
  constructor(
    @repository(AdultRepository)
    public adultRepository : AdultRepository,
  ) {}

  @post('/parents')
  @response(200, {
    description: 'Adult model instance',
    content: {'application/json': {schema: getModelSchemaRef(Adult)}},
  })
  async create(
    @requestBody({
      content: {
        'application/json': {
          schema: getModelSchemaRef(Adult, {
            title: 'NewAdult',
            exclude: ['id'],
          }),
        },
      },
    })
    adult: Omit<Adult, 'id'>,
  ): Promise<Adult> {
    return this.adultRepository.create(adult);
  }

  @get('/parents/count')
  @response(200, {
    description: 'Adult model count',
    content: {'application/json': {schema: CountSchema}},
  })
  async count(
    @param.where(Adult) where?: Where<Adult>,
  ): Promise<Count> {
    return this.adultRepository.count(where);
  }

  @get('/parents')
  @response(200, {
    description: 'Array of Adult model instances',
    content: {
      'application/json': {
        schema: {
          type: 'array',
          items: getModelSchemaRef(Adult, {includeRelations: true}),
        },
      },
    },
  })
  async find(
    @param.filter(Adult) filter?: Filter<Adult>,
  ): Promise<Adult[]> {
    return this.adultRepository.find(filter);
  }

  @patch('/parents')
  @response(200, {
    description: 'Adult PATCH success count',
    content: {'application/json': {schema: CountSchema}},
  })
  async updateAll(
    @requestBody({
      content: {
        'application/json': {
          schema: getModelSchemaRef(Adult, {partial: true}),
        },
      },
    })
    adult: Adult,
    @param.where(Adult) where?: Where<Adult>,
  ): Promise<Count> {
    return this.adultRepository.updateAll(adult, where);
  }

  @get('/parents/{id}')
  @response(200, {
    description: 'Adult model instance',
    content: {
      'application/json': {
        schema: getModelSchemaRef(Adult, {includeRelations: true}),
      },
    },
  })
  async findById(
    @param.path.number('id') id: number,
    @param.filter(Adult, {exclude: 'where'}) filter?: FilterExcludingWhere<Adult>
  ): Promise<Adult> {
    return this.adultRepository.findById(id, filter);
  }

  @patch('/parents/{id}')
  @response(204, {
    description: 'Adult PATCH success',
  })
  async updateById(
    @param.path.number('id') id: number,
    @requestBody({
      content: {
        'application/json': {
          schema: getModelSchemaRef(Adult, {partial: true}),
        },
      },
    })
    adult: Adult,
  ): Promise<void> {
    await this.adultRepository.updateById(id, adult);
  }

  @put('/parents/{id}')
  @response(204, {
    description: 'Adult PUT success',
  })
  async replaceById(
    @param.path.number('id') id: number,
    @requestBody() adult: Adult,
  ): Promise<void> {
    await this.adultRepository.replaceById(id, adult);
  }

  @del('/parents/{id}')
  @response(204, {
    description: 'Adult DELETE success',
  })
  async deleteById(@param.path.number('id') id: number): Promise<void> {
    await this.adultRepository.deleteById(id);
  }
}
