import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: [
      /^http:\/\/localhost:\d+$/,
      'https://elmehdikhachir.github.io',
    ],
  });

  const openApiConfig = new DocumentBuilder()
    .setTitle('Sport Team Manager API')
    .setDescription('REST API for the Sport Team Manager mobile application')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const documentFactory = () =>
    SwaggerModule.createDocument(app, openApiConfig);
  SwaggerModule.setup('docs', app, documentFactory);

  app.enableShutdownHooks();
  await app.listen(process.env.PORT ?? 3000);
}
await bootstrap();
