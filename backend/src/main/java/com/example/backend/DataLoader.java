package com.example.backend;

import com.example.backend.entity.TestEntity;
import com.example.backend.repository.TestRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements CommandLineRunner {

    private final TestRepository testRepository;

    public DataLoader(TestRepository testRepository) {
        this.testRepository = testRepository;
    }

    @Override
    public void run(String... args) {
        // Test verisi ekle
        TestEntity test = new TestEntity();
        test.setMessage("Merhaba AnalizAI! PostgreSQL bağlantısı başarılı! 🎉");
        testRepository.save(test);

        System.out.println("========================================");
        System.out.println("✅ Test verisi başarıyla kaydedildi!");
        System.out.println("📋 Toplam kayıt sayısı: " + testRepository.count());
        System.out.println("========================================");
    }
}
