package amouhal.nouhayla.commande.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.POST, "/api/commandes").hasRole("CLIENT")
                        .requestMatchers(HttpMethod.GET, "/api/commandes").hasRole("CLIENT")
                        .requestMatchers(HttpMethod.GET, "/api/commandes/all").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/commandes/{id}").hasAnyRole("CLIENT", "ADMIN")
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> {}));
        return http.build();
    }
}