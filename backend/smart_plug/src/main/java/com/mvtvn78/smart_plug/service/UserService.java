package com.mvtvn78.smart_plug.service;

import com.mvtvn78.smart_plug.config.JwtService;
import com.mvtvn78.smart_plug.data.*;
import com.mvtvn78.smart_plug.model.Otp;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.repository.OtpRepository;
import com.mvtvn78.smart_plug.repository.UserRepository;
import com.mvtvn78.smart_plug.util.CommonUtil;
import com.mvtvn78.smart_plug.util.OtpUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;

@Service
public class UserService  {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private JwtService jwtTokenUtil;
    @Autowired
    private MailService mailService;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private OtpRepository  otpRepository;
    public ServiceResponse getInfo(){
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        return new ServiceResponse(200,new RegisterResponse(user.getId(),user.getUserName(),user.getEmail(),user.getFullName(),user.getRole()));
    }
    public ServiceResponse login(LoginRequest request) {
        HashMap<String, String> result = new HashMap<>();
        UserDetailsDto userDetailsDto = findByUserNameOrEmail(request.getUserName());
        if(userDetailsDto==null){
            result.put("message", "Invalid username or password");
            return new ServiceResponse(HttpStatus.OK.value(),result);
        }
        if (!passwordEncoder.matches(request.getPassword(), userDetailsDto.getPassword())) {
            result.put("message", "Password Incorrect");
            return new ServiceResponse(HttpStatus.OK.value(),result);
        }
        String token =  jwtTokenUtil.generateToken(userDetailsDto);
        result.put("token", token);
        return new ServiceResponse(HttpStatus.OK.value(),result);
    }
    @Transactional(rollbackFor = Exception.class)
    public ServiceResponse register(RegisterRequest request) {
        HashMap<String, String> result = new HashMap<>();
        if(!request.getPassword().equals(request.getConfirmPassword())){
            result.put("message","Passwords do not match");
            return new ServiceResponse(209, result);
        }
        UserDetailsDto userDetailsDto = findByUserNameOrEmail(request.getUserName(),request.getEmail());
        if(userDetailsDto!=null){
            result.put("message","User exist");
            return new ServiceResponse(209, result);
        }
        User user = new User();
        user.setUserName(request.getUserName());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setFullName(request.getFullName());
        user.setRole(CommonUtil.ROLE_USER);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);
        return new ServiceResponse(HttpStatus.OK.value(),new RegisterResponse(user.getId(),user.getUserName(),user.getEmail(),user.getFullName(),user.getRole()));
    }
    @Transactional(rollbackFor = Exception.class)
    public ServiceResponse forgot(ForgotPwdRequest request) {
        String subject ="Forgot Password";
        String from ="\"Smart Plug 👻\" <89@tlus.edu.vn>";
        HashMap<String, String> result = new HashMap<>();
        User user = userRepository.findByEmail(request.getEmail());
        if(user==null){
            result.put("message","Send OTP Unsuccessful");
            return new ServiceResponse(404, result);
        }
        boolean valid = user.getOtpTime() == null;
        if(user.getOtpTime()!=null){
            LocalDateTime now = LocalDateTime.now();
            Duration duration = Duration.between(user.getOtpTime(), now);
            // 5 Phút sau gửi lại
            valid= valid || duration.toMinutes() >= 5;
        }
        if(!valid){
            result.put("message","Send Request after 5 minutes");
            return new ServiceResponse(209, result);
        }
        int otpValue = OtpUtils.generateOtp();
        Otp newOtp = new Otp();
        newOtp.setEmail(request.getEmail());
        newOtp.setValue(otpValue);
        newOtp.setActive(false);
        otpRepository.save(newOtp);
        user.setOtpTime(newOtp.getCreateAt());
        userRepository.save(user);
        String txt = "OTP: " + otpValue;
        mailService.sendMail(from,request.getEmail(),subject,txt);
        result.put("message","Send OTP Successfully");
        return new ServiceResponse(HttpStatus.OK.value(),result);
    }
    @Transactional(rollbackFor = Exception.class)
    public ServiceResponse changePasswordWithOtp(ChangePwdOtpRequest request){
        HashMap<String, String> result = new HashMap<>();
        if(!request.getNewPwd().equals(request.getConfirmPwd())){
            result.put("message","Passwords do not match");
            return new ServiceResponse(209, result);
        }
        Otp findOtp = otpRepository.findByEmailAndValue(request.getEmail(),request.getOtp());
        if(findOtp == null || !OtpUtils.isOtpValid(findOtp))
        {
            result.put("message","Invalid OTP");
            return new ServiceResponse(209, result);
        }
        findOtp.setActive(true);
        otpRepository.save(findOtp);
        User user = userRepository.findByEmail(request.getEmail());
        boolean isChange = updatePassword(user,request.getNewPwd());
        if(isChange){
            result.put("message","Change Password Successfully");
            return new ServiceResponse(HttpStatus.OK.value(),result);
        }
        result.put("message","Change Password Unsuccessfully");
        return new ServiceResponse(HttpStatus.UNAUTHORIZED.value(),result);
    }
    @Transactional(rollbackFor = Exception.class)
    public ServiceResponse changePassword(ChangePwdRequest request) {
        HashMap<String, String> result = new HashMap<>();
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        if(!request.getNewPwd().equals(request.getConfirmPwd())){
            result.put("message","Password confirm do not match");
            return new ServiceResponse(209,result);
        }
        User user = userRepository.findByUserName(userName);
        if(!passwordEncoder.matches(request.getOldPwd(),user.getPassword())){
            result.put("message","Old Password Do not Match");
            return new ServiceResponse(HttpStatus.UNAUTHORIZED.value(),result);
        }
        boolean isChange = updatePassword(user,request.getNewPwd());
        if(isChange){
            result.put("message","Change Password Successfully");
            return new ServiceResponse(HttpStatus.OK.value(),result);
        }
        result.put("message","Change Password Unsuccessfully");
        return new ServiceResponse(HttpStatus.UNAUTHORIZED.value(),result);
    }
    public ServiceResponse changeFullName(ChangeFullNameRequest request) {
        HashMap<String, String> result = new HashMap<>();
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        boolean isChange = updateFullName(user,request.getFullName());
        if(isChange){
            result.put("message","Change FullName Successfully");
            return new ServiceResponse(HttpStatus.OK.value(),result);
        }
        result.put("message","Change FullName Unsuccessfully");
        return new ServiceResponse(HttpStatus.UNAUTHORIZED.value(),result);
    }
    public boolean updateFullName(User user, String newFullName) {
        if(user ==null){
            return false;
        }
        user.setFullName(newFullName);
        userRepository.save(user);
        return true;
    }
    public boolean updatePassword(User user, String newPassword) {
        if(user==null){
            return false;
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        return true;
    }
    public UserDetailsDto findByUserName(String userName){
        User user = userRepository.findByUserName(userName);
        if(user == null){
            return null;
        }
        return new UserDetailsDto(user.getUserName(),user.getPassword(),user.getRole());
    }
    public UserDetailsDto findByUserNameOrEmail(String txt){
        return findByUserNameOrEmail(txt,txt);
    }
    public UserDetailsDto findByUserNameOrEmail(String username, String email){
        UserDetailsDto userDetailsDto = findByUserName(username);
        if(userDetailsDto==null){
            userDetailsDto = findByEmail(email);
        }
        return userDetailsDto;
    }
    public UserDetailsDto findByEmail(String email){
        User user = userRepository.findByEmail(email);
        if(user == null){
            return null;
        }
        return  new UserDetailsDto(user.getUserName(),user.getPassword(),user.getRole());
    }


}
