package com.mvtvn78.smart_plug.config;

import com.mvtvn78.smart_plug.data.UserDetailsDto;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.repository.UserRepository;
import com.mvtvn78.smart_plug.service.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@Slf4j
public class JwtRequestFilter extends OncePerRequestFilter {
    @Autowired
    private JwtService jwtTokenUtil;
    @Autowired
    private UserService userService;
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");
        String jwt;
        String userName = null;
        if (authHeader == null ||!authHeader.startsWith("Bearer ")) {
            chain.doFilter(request, response);
            return;
        }
        jwt = authHeader.substring(7);
        if (jwt.equals("null")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Invalid Token");
            return;
        }
        if (jwtTokenUtil.isTokenExpired(jwt)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Invalid Token");
            return;
        }
        userName = jwtTokenUtil.extractUsername(jwt);
        if (userName != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userService.findByUserName(userName);
            if(userDetails==null){
                throw new UsernameNotFoundException("Tài khoản " + userName + " không tồn tại");
            }
            if (jwtTokenUtil.isTokenValid(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        chain.doFilter(request, response);
    }
}
