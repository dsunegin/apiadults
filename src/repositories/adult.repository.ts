import {inject} from '@loopback/core';
import {DefaultCrudRepository} from '@loopback/repository';
import {DbvideoDataSource} from '../datasources';
import {Adult, AdultRelations} from '../models';

export class AdultRepository extends DefaultCrudRepository<
  Adult,
  typeof Adult.prototype.id,
  AdultRelations
> {
  constructor(
    @inject('datasources.dbvideo') dataSource: DbvideoDataSource,
  ) {
    super(Adult, dataSource);
  }
}
