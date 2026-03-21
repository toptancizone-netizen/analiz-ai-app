package com.example.backend.config;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Merkezi API Yapılandırma Sınıfı
 * Tüm ücretsiz API token'ları, anahtarları ve endpoint'leri burada tanımlanır.
 * Değerler application.properties dosyasından okunur.
 *
 * API Kullanım Haritası:
 * ─────────────────────────────────────────────────────────────
 * Nominatim (OpenStreetMap) → Rakip bulma, adres arama, mahalle trendleri
 * Hugging Face Inference    → Yorum analizi, duygu analizi, fiyat/kampanya önerisi
 * İyzico Sandbox            → Abonelik, ödeme, 3D Secure, taksit
 * Firebase                  → Google Sign-In, push bildirim, analytics
 * ─────────────────────────────────────────────────────────────
 */
@Configuration
@Getter
public class ApiConfig {

    // ═══════════════════════════════════════════════════════════
    // HUGGING FACE — AI Analiz (Yorum, Duygu, Fiyat, Kampanya)
    // ═══════════════════════════════════════════════════════════

    @Value("${app.huggingface.token}")
    private String huggingfaceToken;

    @Value("${app.huggingface.base-url}")
    private String huggingfaceBaseUrl;

    @Value("${app.huggingface.model.sentiment}")
    private String huggingfaceSentimentModel;

    @Value("${app.huggingface.model.ner}")
    private String huggingfaceNerModel;

    @Value("${app.huggingface.model.text-generation}")
    private String huggingfaceTextGenerationModel;

    // ═══════════════════════════════════════════════════════════
    // İYZİCO SANDBOX — Ödeme & Abonelik
    // ═══════════════════════════════════════════════════════════

    @Value("${app.iyzico.api-key}")
    private String iyzicoApiKey;

    @Value("${app.iyzico.secret-key}")
    private String iyzicoSecretKey;

    @Value("${app.iyzico.merchant-id}")
    private String iyzicoMerchantId;

    @Value("${app.iyzico.base-url}")
    private String iyzicoBaseUrl;

    // ═══════════════════════════════════════════════════════════
    // NOMINATIM (OpenStreetMap) — Harita & Rakip Bulma
    // ═══════════════════════════════════════════════════════════

    @Value("${app.nominatim.base-url}")
    private String nominatimBaseUrl;

    @Value("${app.nominatim.user-agent}")
    private String nominatimUserAgent;

    // ═══════════════════════════════════════════════════════════
    // FIREBASE — Auth & Push & Analytics
    // ═══════════════════════════════════════════════════════════

    @Value("${app.firebase.project-id}")
    private String firebaseProjectId;

    // ─── Helper Methods ────────────────────────────────────────

    /**
     * Hugging Face API için Authorization header döner.
     */
    public String getHuggingfaceAuthHeader() {
        return "Bearer " + huggingfaceToken;
    }

    /**
     * Belirtilen model için tam Hugging Face inference URL'sini döner.
     */
    public String getHuggingfaceModelUrl(String modelId) {
        return huggingfaceBaseUrl + "/" + modelId;
    }

    /**
     * Duygu analizi modeli için tam URL döner.
     */
    public String getSentimentModelUrl() {
        return getHuggingfaceModelUrl(huggingfaceSentimentModel);
    }

    /**
     * NER (Named Entity Recognition) modeli için tam URL döner.
     */
    public String getNerModelUrl() {
        return getHuggingfaceModelUrl(huggingfaceNerModel);
    }

    /**
     * Metin üretim modeli için tam URL döner.
     */
    public String getTextGenerationModelUrl() {
        return getHuggingfaceModelUrl(huggingfaceTextGenerationModel);
    }
}
