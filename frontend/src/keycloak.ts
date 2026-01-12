import Keycloak from 'keycloak-js';

const keycloak = new (Keycloak as any)({
  url: 'http://localhost:8180/',
  realm: 'microservices-app',
  clientId: 'frontend-client',
});

export default keycloak;
