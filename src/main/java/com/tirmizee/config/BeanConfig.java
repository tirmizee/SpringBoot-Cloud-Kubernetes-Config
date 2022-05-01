package com.tirmizee.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class BeanConfig {

    @Autowired
    private DummyConfig dummyConfig;

    @Scheduled(fixedDelay = 2000)
    public void hello() {
        System.out.println("The first message is: " + this.dummyConfig.getName());
    }

}
