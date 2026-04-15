return {
    -- System instruction
    system_instruction = "Sen uzman bir edebiyat eleştirmeni ve araştırmacısısın. Yanıtın YALNIZCA geçerli JSON formatında olmalıdır. JSON yapısı dışında herhangi bir metin ekleme. Verilerin son derece doğru olduğundan ve kesinlikle belirtilen kitapla ilgili olduğundan emin ol.",
    
    -- Main prompt (Full book analysis)
    main = [[Kitap: "%s" - Yazar: %s
Bu kitap için detaylı X-Ray verileri oluştur. Aşağıdaki JSON formatını TAMAMEN doldur.

TEMEL KURALLAR:
1. YALNIZCA BU kitaptan veri dahil et. Doğru eseri analiz ettiğinden emin olmak için sağlanan başlığı, yazarı ve dosya adını kullan.
2. KARAKTERLER: En az 15-20 karakter listele. Tüm ana karakterleri, önemli yardımcı karakterleri ve kayda değer yan figürleri dahil et.
3. MEKANLAR: Kitapta açıklanan en az 10-15 önemli mekanı listele.
4. TARİHİ KİŞİLER: Kitapta adı geçen veya kurguyla ilgili en az 5-10 gerçek dünya tarihi kişisini belirle. Eğer kurgusal bir dünyaysa, o dünyanın tarihindeki önemli efsanevi veya tarihi figürleri listele.
5. DETAYLAR: Zengin ve gerçekçi açıklamalar sağla. Belirsiz genellemelerden kaçın.
6. JSON: Çıktı tek bir geçerli JSON nesnesi OLMALIDIR.

GEREKLİ JSON FORMATI:
{
  "book_title": "Kitabın Tam Adı",
  "author": "Yazar Adı",
  "author_bio": "Yazarın biyografisi, tarzına ve bu spesifik eserine odaklanarak.",
  "summary": "Kitabın konusu ve olay örgüsünün kapsamlı özeti (Spoiler içermeyen).",
  "characters": [
    {
      "name": "Karakter Adı",
      "role": "Ana Karakter / Yardımcı / Antagonist",
      "gender": "Erkek / Kadın / Diğer",
      "occupation": "Statü veya iş",
      "description": "Kişilik ve önem dahil olmak üzere 3-4 cümlelik detaylı karakter analizi."
    }
  ],
  "historical_figures": [
    {
      "name": "Kişi Adı",
      "role": "Tarihi Rolü",
      "biography": "Kısa biyografi",
      "importance_in_book": "Bu spesifik kitapta neden adı geçiyor?",
      "context_in_book": "Göründüğü spesifik sahne veya tartışma"
    }
  ],
  "locations": [
    {"name": "Mekan Adı", "description": "Görsel ve atmosferik açıklama", "importance": "Anlatıdaki önemi"}
  ],
  "themes": ["Detaylı Tema 1", "Detaylı Tema 2", "Detaylı Tema 3", "Detaylı Tema 4", "Detaylı Tema 5"],
  "timeline": [
    {"event": "Önemli Olay", "chapter": "Bölüm Adı/Numarası", "importance": "Bunun hikaye için neden önemli olduğu"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Kitap: "%s" - Yazar: %s
KRİTİK: Okuyucu bu kitabın yalnızca %%%d'sini okudu. YALNIZCA bu noktaya kadar olan içeriği kapsayan X-Ray verileri sağlamalısın.

KESİN SPOILER KURALLARI:
1. %%%d işaretinden SONRA tanıtılan hiç bir karakteri dahil etme.
2. %%%d işaretinden SONRA gerçekleşen hiç bir olay örgüsü, ters köşe veya ölümü dahil etme.
3. %%%d işaretinden SONRA gerçekleşen hiç bir karakter gelişimi veya kimlik açığa çıkmasını dahil etme.
4. "Özet" (summary) ve "zaman çizelgesi" (timeline) tam olarak %%%d noktasında durmalıdır.
5. Karakter "açıklamaları" (descriptions) yalnızca %%%d noktasındaki durumlarını ve bilgilerini yansıtmalıdır.

ÖĞE SAYISI KURALLARI:
1. KARAKTERLER: Bu noktaya kadar karşılaşılan 10-15 karakteri listele.
2. MEKANLAR: Bu noktaya kadar ziyaret edilen veya adı geçen 8-12 mekanı listele.
3. ZAMAN ÇİZELGESİ: Halihazırda gerçekleşmiş 8-12 ana olayı listele.

GEREKLİ JSON FORMATI:
{
  "book_title": "Kitap Adı",
  "author": "Yazar Adı",
  "author_bio": "Biyografi",
  "summary": "YALNIZCA şimdiye kadar okunan kısmın özeti (%%%d)",
  "characters": [
    {
      "name": "Ad",
      "role": "Şu an algılanan rol",
      "gender": "Cinsiyet",
      "occupation": "Mevcut meslek",
      "description": "Karakterin TAM OLARAK %%%d noktasındaki durumu. Gelecekteki sırları açığa çıkarma."
    }
  ],
  "historical_figures": [
    {
      "name": "Ad",
      "role": "Rol",
      "biography": "Biyografi",
      "importance_in_book": "Şimdiye kadarki önemi",
      "context_in_book": "Bahsedilme bağlamı"
    }
  ],
  "locations": [
    {"name": "Ad", "description": "Açıklama", "importance": "Şimdiye kadarki önemi"}
  ],
  "themes": ["Bu noktaya kadar belirgin olan temalar"],
  "timeline": [
    {"event": "ZATEN gerçekleşmiş olay", "chapter": "Bölüm", "importance": "Önemi"}
  ]
}]],

    -- Fallback strings
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
