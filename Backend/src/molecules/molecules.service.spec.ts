import { Test, TestingModule } from '@nestjs/testing';
import { MoleculesService } from './molecules.service';

describe('MoleculesService', () => {
  let service: MoleculesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [MoleculesService],
    }).compile();

    service = module.get<MoleculesService>(MoleculesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
