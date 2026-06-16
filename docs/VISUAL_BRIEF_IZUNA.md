# Izuna - Visual Development Brief

**Status:** Canonical master approved; turnaround preparation next  
**Character:** Izuna, The Sacred Edge  
**Gameplay role:** Fast rushdown / all-rounder  
**Fragment:** Law of Memory  

Dokumen ini menjadi batas produksi visual pertama. Tujuannya belum membuat sprite final, melainkan mengunci silhouette, proporsi, dan bahasa bentuk yang cocok dengan ukuran gameplay.

## 1. First Drawing Goal

Buat satu concept board hemat credit berisi:

- Satu full-body combat pose utama, front three-quarter view.
- Tiga silhouette kecil dengan variasi bentuk pakaian dan memory flame.
- Satu close-up kepala untuk ekspresi dan mask motif.
- Swatch warna inti.

Belum membuat turnaround lengkap, sprite sheet, animation strip, ultimate art, atau UI portrait final.

## 2. Gameplay Scale

- Tinggi hurtbox prototype: 176 gameplay pixels.
- Lebar badan prototype: 76 gameplay pixels.
- Karakter harus tetap terbaca ketika ditampilkan sekitar 180-220 pixels di layar 1280x720.
- Pedang dan flame trail boleh melewati hurtbox, tetapi pose badan tetap terbaca tanpa efek.
- Silhouette tidak boleh bergantung pada detail kecil.

## 3. Character Read

Dalam satu detik pemain harus membaca:

> Sacred fox swordsman who carries the memories of a broken world.

Izuna harus terlihat:

- Cepat, terkendali, dan berpengalaman.
- Suci tanpa terlihat seperti paladin Eropa.
- Membawa kesedihan lama tanpa menjadi muram pasif.
- Berbahaya karena presisi, bukan karena tubuh besar.

## 4. Originality Direction

Desain awal terinspirasi motif fox hero yang disukai director, tetapi versi final harus menjauh dari Kamen Rider Geats dan IP lain.

Hindari:

- Rider helmet atau mata visor besar.
- Armor tokusatsu putih-merah-hitam.
- Pola helm, dada, atau belt yang menyerupai transformation device.
- Silhouette jaket rider modern.
- Menyalin karakter kitsune anime yang sudah dikenal.

Gunakan arah original:

- Wajah manusia terlihat jelas.
- Porcelain memory mask berbentuk abstrak, dipakai sebagai half-mask atau digantung di pinggang.
- Asymmetrical shrine-warrior clothing.
- Layer pakaian tipis yang mengikuti dash dan slash.
- Memory flame berbentuk fragmen kaligrafi, bukan api biasa.
- Fox motif muncul melalui negative space, ear-like hair ornaments, dan flame tails.

## 5. Silhouette

- Tubuh atletis ramping, sekitar 7.5 heads tall.
- Stance rendah dengan bahu santai dan pedang siap draw slash.
- Satu sisi kostum lebih panjang untuk menciptakan arah gerak.
- Tiga flame-tail wisps terlihat saat neutral; sembilan hanya muncul saat Ultimate.
- Pedang sedikit lebih panjang dari katana standar agar jangkauan Medium dan Heavy terbaca.
- Tidak memakai cape besar yang menutupi tangan atau hit reaction.

## 6. Costume

- Inner layer: fitted charcoal combat wrap.
- Outer layer: broken-white asymmetrical short haori.
- Lower body: tapered hakama-inspired trousers yang tetap mendukung kick silhouette.
- Crimson cords menyimpan engraved memory fragments.
- Forearm guard sederhana pada tangan pedang.
- Footwear ringan untuk dash, tanpa armor boots besar.
- Bekas jahitan atau repair line menunjukkan pakaian telah bertahan 120 tahun.

## 7. Head and Expression

- Young-adult appearance despite actual age.
- Calm, focused eyes with restrained anger.
- Hair mostly dark charcoal or pale ash; one crimson memory streak.
- Fox-ear impression berasal dari hair ornament atau flame shape, bukan telinga hewan literal.
- Mask motif memakai retakan melingkar dan memory glyph original.

## 8. Weapon

Working name: **The Remembered Edge**.

- Single-edged curved sword.
- Dark metal spine with pale cutting edge.
- Crimson glyphs emerge only during attacks.
- Guard shape references a broken Covenant ring.
- Scabbard remains compact and does not dominate idle silhouette.

## 9. Color Palette

- Broken white: sacred memory and erased history.
- Charcoal: grief, restraint, and readable body mass.
- Crimson: memory flame and active attack language.
- Small muted gold accent: old Covenant heritage.
- Avoid equal distribution; charcoal forms the body, white defines outer shape, crimson marks action.

## 10. VFX Language

- Crimson-white brush stroke.
- Fragmented calligraphy and broken circular glyphs.
- Flame moves like remembered ink being replayed.
- Normal attacks use thin white-red accents.
- Memory Mark uses one small broken-ring glyph.
- No large particle cloud around idle pose.

## 11. First Generation Constraints

- Transparent or plain neutral background.
- No scenery and no poster composition.
- No readable text generated inside the image.
- No sprite sheet yet.
- No multiple weapons.
- No oversized armor.
- No chibi proportions.
- Preserve hands, sword grip, feet, and full silhouette.
- Production concept art, not a finished marketing splash.

## 12. Approval Criteria

The first concept passes when:

- Silhouette reads at thumbnail size.
- It no longer resembles a Kamen Rider suit.
- Sword, hands, and movement cloth are animation-friendly.
- White, charcoal, and crimson remain distinct against a dark stage.
- The design can be simplified into separated skeletal-animation parts.
- Director recognizes Izuna's original fantasy immediately.

## 13. Next Visual Steps

After the concept board is approved:

1. Lock one silhouette route.
2. Produce clean front three-quarter master design.
3. Produce simplified front, side, and back turnaround.
4. Define separated body parts for Skeleton2D.
5. Create idle key pose and first attack key pose.
6. Validate the approved pose at gameplay scale before any animation strip.

## 14. Generated Concept

- Concept board: `res://assets/characters/izuna/concept/izuna-concept-board-v01.png`
- Review notes: `res://docs/visual-development/IZUNA_CONCEPT_V01_REVIEW.md`
- Approved master: `res://assets/characters/izuna/concept/izuna-master-concept-v01.png`
- Lock record: `res://docs/visual-development/IZUNA_MASTER_V01_REVIEW.md`
