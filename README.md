# syncSound

Vite + TypeScript static web app. The browser detects its preferred language on first visit and users can switch between Thai, English, Japanese, Korean, and Chinese. No user session is stored except the selected language in the browser.

เว็บเล็ก ๆ สำหรับเปิด YouTube หลายเวอร์ชัน แล้วจัดตำแหน่งเสียงให้ตรงกับแทร็กหลัก (Master)

## Auto alignment และการจูนเอง

ระบบจะคุม **drift** ระหว่างเล่นอัตโนมัติอยู่แล้ว: เมื่อเหลื่อมเล็กน้อยจะปรับ speed ชั่วคราว และเมื่อเหลื่อมมากจะ seek กลับให้ตรงกับ Master

สำหรับเพลงคนละเวอร์ชันที่มี intro หรือจุดเริ่มต่างกัน ให้เลื่อนทั้งสองวิดีโอไปยังคำร้องหรือ beat เดียวกัน แล้วกด **จับจุดนี้** ที่แทร็กรอง ระบบจะคำนวณ Offset จากตำแหน่งปัจจุบันให้ จากนั้นใช้ปุ่ม `−` / `+` เพื่อจูนทีละ 0.05 วินาที หรือกรอกค่า Offset เองได้ตลอด

YouTube iframe ไม่เปิด raw audio stream ให้ browser จึงไม่สามารถทำ audio fingerprint/beat detection ของเพลงสองคลิปแบบอัตโนมัติจริง ๆ ได้โดยไม่เพิ่มบริการประมวลผลเสียงภายนอก

## Deploy ด้วย Docker Compose

```powershell
docker compose up -d --build
```

จากนั้นเปิด `http://localhost:8787` หรือเปลี่ยน `8787:80` ใน `docker-compose.yml` เป็นพอร์ตที่ต้องการ ตัวเว็บถูกเสิร์ฟผ่าน Nginx จึงให้ referrer/origin ที่ YouTube ต้องการได้

For local development, run `npm install` once and then `npm run dev`.

## Search visibility

The production site includes canonical metadata, Open Graph metadata, structured data, `robots.txt`, and `sitemap.xml` for `https://syncsound.einzberz.com/`. After deployment, add the domain to Google Search Console, verify ownership, then submit `https://syncsound.einzberz.com/sitemap.xml`. Indexing is not immediate and search ranking is not guaranteed.

## วิธีใช้

1. **ห้ามดับเบิลคลิก `index.html` โดยตรง** เพราะ YouTube จะตอบ error 153 เมื่อไม่มี referrer
2. เปิดผ่าน local web server: คลิกขวา `start.ps1` แล้วเลือก **Run with PowerShell** จากนั้นเข้า `http://localhost:4173`
   - หรือใช้ VS Code Live Server ก็ได้
3. วาง YouTube link เพื่อเพิ่มแต่ละเวอร์ชัน
4. กด **เล่นทั้งหมด** แล้วแก้ค่า **Offset** เป็นวินาทีจนจุดที่ต้องการฟังตรงกัน
5. กด **จัดให้ตรงตอนนี้** เพื่อ seek ทุกแทร็กเข้าตำแหน่งที่คำนวณไว้ทันที

`Offset +1.500s` หมายถึงแทร็กนั้นจะอยู่หน้า Master 1.5 วินาที ส่วนค่า negative จะอยู่หลัง Master

## การทำงาน

- ใช้ YouTube IFrame Player API โดยรับเฉพาะ `youtube.com` และ `youtu.be`
- ทุก 150ms จะเปรียบเทียบเวลาปัจจุบันของแต่ละ player กับ Master + Offset
- drift น้อย: ลด/เพิ่ม playback rate ชั่วคราว (0.92x / 1.08x)
- drift มากกว่า 0.35 วินาที: seek กลับเข้าตำแหน่งเป้าหมาย

ข้อจำกัด: YouTube และเบราว์เซอร์ไม่ให้ควบคุมเสียงระดับ sample-accurate; จึงไม่มีทางรับประกันว่าเสียงสอง stream จะตรง 100% โดยเฉพาะอินเทอร์เน็ตหน่วงหรือเครื่องกำลังโหลดหนัก แต่ระบบนี้ออกแบบเพื่อคุมให้ drift เล็กและแก้เมื่อหลุดครับ
