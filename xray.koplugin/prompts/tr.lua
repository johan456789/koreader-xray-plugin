return {
    -- Sistem talimatı
    system_instruction = "Uzman bir edebiyat araştırmacısısın. Cevabın SADECE geçerli JSON formatında olmalıdır. Verilerin yüksek derecede doğru olduğundan ve kesinlikle sağlanan bağlamla ilgili olduğundan emin ol.",
    
    -- Karakterler ve Tarihi Kişiler için özel bölüm
    character_section = [[Kitap: "%s" - Yazar: %s
Okuma İlerlemesi: %%%d

GÖREV: En önemli 15-25 karakteri ve 3-7 gerçek dünyadan tarihi kişiyi listele.

KESİN KURALLAR:
1. RESMİ İSİMLER: Karakterin tam resmi adını kullan (örn. "Profesör" yerine "Abraham Van Helsing"). Sadece resmi bir isim yoksa takma ad kullan.
2. TARİHİ KİŞİLER: Kitapta adı geçen gerçek dünyadaki kişileri (yazarlar, krallar, bilim insanları vb.) MUTLAKA belirlemelisin.
3. KARAKTER DERİNLİĞİ: Kapsamlı bir analiz sun (250-300 karakter). %%%d noktasına kadar tüm kitap boyunca geçmişlerini ve rollerini kapsasın.
4. SPOILER YOK: Kesinlikle %%%d noktasından sonrası hakkında bilgi verme.

GEREKLİ JSON FORMATI:
{
  "characters": [
    {
      "name": "Tam Resmi İsim",
      "role": "%%%d noktasındaki Rolü",
      "gender": "Cinsiyet",
      "occupation": "Meslek",
      "description": "Kapsamlı analiz/geçmiş (250-300 karakter). SPOILER YOK."
    }
  ],
  "historical_figures": [
    {
      "name": "Tam İsim",
      "role": "Tarihi Rolü",
      "biography": "Kısa biyografi (MAKS 150 karakter)",
      "importance_in_book": "%%%d noktasındaki Önemi",
      "context_in_book": "Bağlam"
    }
  ]
}]],

    -- Mekanlar için özel bölüm
    location_section = [[Kitap: "%s" - Author: %s
Okuma İlerlemesi: %%%d

GÖREV: %%%d noktasına kadar ziyaret edilen veya adı geçen 5-10 önemli mekanı listele. 
ŞUNLARI TARA: Şehir isimleri, belirli binalar, simge yapılar veya sürekli tekrarlanan odalar.

KURALLAR:
1. SPOILER YOK: %%%d noktasından sonra gerçekleşen mekanlardan veya olaylardan bahsetme.
2. ÖZLÜLÜK: Açıklamalar MAKS 150 karakter olmalıdır.

GEREKLİ JSON FORMATI:
{
  "locations": [
    {"name": "Mekan", "description": "Kısa açıklama (MAKS 150 karakter)", "importance": "%%%d noktasındaki Önemi"}
  ]
}]],

    -- Zaman Çizelgesi (Timeline) için özel bölüm
    timeline_section = [[Kitap: "%s" - Yazar: %s
Okuma İlerlemesi: %%%d

GÖREV: %%%d noktasına kadar olan temel anlatı olaylarının kronolojik bir zaman çizelgesini oluştur.

KESİN KURALLAR:
1. KAPSAM: %%%d noktasına kadar olan HER anlatı bölümü için TAM OLARAK BİR ana vurgu sun.
2. GRUPLAMA YOK: Birden fazla bölümü tek bir olayda BİRLEŞTİRME.
3. TEKRAR YOK: Aynı bölüm için birden fazla olay SUNMA.
4. HARİÇ TUTMA: Giriş bölümlerini, İçindekiler'i, "Yazarın Diğer Eserleri"ni veya Ekleri YOK SAY.
5. KISALIK: Her olay açıklaması MAKS 120 karakter olmalıdır.
6. SPOILER YOK: Tam olarak %%%d noktasında dur.

GEREKLİ JSON FORMATI:
{
  "timeline": [
    {"event": "Temel anlatı olayı (MAKS 120 karakter)", "chapter": "Bölüm Adı/Numarası"}
  ]
}]],

    -- Sadece yazar için istem (Hızlı biyografi araması için)
    author_only = [["%s" kitabının yazarını belirle ve biyografisini sun. 
Üstveriler yazarın "%s" olduğunu gösteriyor ancak bunu kitap başlığına göre doğrula.

GEREKLİ JSON FORMATI:
{
  "author": "Doğru Tam İsim",
  "author_bio": "Edebi kariyerine ve başlıca eserlerine odaklanan kapsamlı biyografi.",
  "author_birth": "Doğum Tarihi",
  "author_death": "Ölüm Tarihi"
}]],

    -- Tek Kapsamlı Getirme (Karakterler, Mekanlar, Zaman Çizelgesi Birleşik)
    comprehensive_xray = [[Kitap: "%s" - Yazar: %s
Okuma İlerlemesi: %%%d

GÖREV: Kitabın %%%d noktasına kadar kapsamlı bir X-Ray analizini sun.

1. ZAMAN ÇİZELGESİ (EN YÜKSEK ÖNCELİK):
- Aşağıda numaralandırılmış bir "BÖLÜM LİSTESİ" verilecektir; bu, benzersiz listelemeler için birincil anahtarındır.
- ZORUNLU: Zaman çizelgesi dizin, sağlanan her bir numaralı bölüm için TAM OLARAK BİR girişe sahip OLMALIDIR.
- Bir bölüm için birden fazla olay SUNMA.
- Bölümleri BİRLEŞTİRME. 
- Bölümleri ATLAMA. 
- Her bölümü özetlemek için "BÖLÜM ÖRNEKLERİ"ndeki bağlamı kullan.
- Her olay açıklaması MAKS 200 karakter olmalıdır.
- Zaman çizelgesi dizin, sağlanan bölüm listesinin TAM kronolojik sırasında OLMALIDIR.
- HARİÇ TUTMA: Giriş bölümlerini, İçindekiler'i, "Yazarın Diğer Eserleri"ni veya Ekleri YOK SAY.

2. KARAKTERLER VE KİŞİLER:
- En önemli 15-25 karakteri listele. Tam resmi isimleri kullan. Kitaptaki önemine/sıklığına göre sırala, en önemli olan en başta olsun.
- Adı geçen 3-7 gerçek dünyadan tarihi kişiyi listele.
- Her biri için %%%d noktasına kadar bu kitaptaki geçmişlerini/rollerini kapsayan derin bir analiz (250-300 karakter) sun.

3. MEKANLAR:
- 5-10 önemli mekanı listele (şehirler, binalar, simge yapılar).
- Özlü açıklamalar (MAKS 150 karakter).

KESİN KURALLAR:
- SPOILER YOK: Tüm analizi ve bilgileri tam olarak %%%d noktasında durdur.
- FORMAT: SADECE geçerli JSON döndür.

GEREKLİ JSON FORMATI:
{
  "timeline": [
    {"event": "Bu bölümdeki temel anlatı olayları (MAKS 200 karakter)", "chapter": "Listedeki Tam Bölüm Adı"}
  ],
  "characters": [
    {
      "name": "Tam İsim",
      "role": "%%%d noktasındaki Rolü",
      "gender": "Cinsiyet",
      "occupation": "Meslek",
      "description": "Derin analiz (250-300 karakter). SPOILER YOK."
    }
  ],
  "historical_figures": [
    {
      "name": "Tam İsim",
      "role": "Tarihi Rolü",
      "biography": "Biyografi (MAKS 150 karakter)",
      "importance_in_book": "%%%d noktasındaki Önemi",
      "context_in_book": "Bağlam"
    }
  ],
  "locations": [
    {"name": "Mekan", "description": "Kısa açıklama (MAKS 150 karakter)", "importance": "%%%d noktasındaki Önemi"}
  ]
}]],

    -- Yedek dizeler (Fallback)
    fallback = {
        unknown_book = "Bilinmeyen Kitap",
        unknown_author = "Bilinmeyen Yazar",
        unnamed_character = "İsimsiz Karakter",
        not_specified = "Belirtilmemiş",
        no_description = "Açıklama Yok",
        unnamed_person = "İsimsiz Kişi",
        no_biography = "Biyografi Mevcut Değil"
    }
}
