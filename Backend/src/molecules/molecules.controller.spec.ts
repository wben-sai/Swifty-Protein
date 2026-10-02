import { Test, TestingModule } from '@nestjs/testing';
import { MoleculesController } from './molecules.controller';

describe('MoleculesController', () => {
  let controller: MoleculesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MoleculesController],
    }).compile();

    controller = module.get<MoleculesController>(MoleculesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
