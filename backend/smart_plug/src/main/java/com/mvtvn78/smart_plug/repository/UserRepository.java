package com.mvtvn78.smart_plug.repository;

import com.mvtvn78.smart_plug.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUserName(String userName);

    User findByEmail(String email);
}
