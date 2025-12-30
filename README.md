# VHDL TextIO Correct Usage Examples
This repository provides **bug-free, practical usage examples** for `std.textio` in VHDL.
It focuses on correct patterns for reading text files in simulations, especially the cases where
online snippets often fail (EOF handling, re-reading files, sequential multi-file processing).

-------------------------------
## What’s inside
Four essential patterns are covered:

- **Single file – read once**
- **Single file – read repeatedly**
- **Multiple files – read once (sequentially)**
- **Multiple files – read repeatedly (sequential sets)**

> Note: This repo is about **correct usage patterns**. It does not modify the `std.textio` package itself.

## Repository structure
- **read_once.vhd** - Single file, one pass
- **Sread_repeat.vhd** - Single file, multiple passes (close/reopen pattern)
- **multi_once.vhd** - Multiple files, one pass each (sequential)
- **multi_repeat.vhd** - Multiple files, repeated reads (sequential + loops)

## Usage (ModelSim / Vivado / ISE)
1. **Extract/clone** this repository to a path you like.
2. Create a **new project** in your simulator (ModelSim / Vivado / ISE).
3. **Add Sources**

> Note: In VHDL strings on Windows, use double backslashes like this : D:\\project\\new106\\data1.txt and don't forget to update them inside the example files to match your system.

## Which file should be used?
- Want to read **one file one time** → `examples/read_once.vhd`
- Want to read **the same file multiple times** → `examples/read_repeat.vhd`
- Want to read **multiple files sequentially (each once)** → `examples/multi_once.vhd`
- Want to read **multiple files sequentially, repeated cycles** → `examples/multi_repeat.vhd`

## Tips for avoiding common TextIO bugs
- Always handle `endfile(fptr)` correctly to avoid infinite loops.
- Close files properly when switching between files.
- For re-reading a file, use a close/reopen strategy (don’t assume “rewind” exists everywhere).
- Keep file-path strings in one place (constants) so changes are easy.

## 📞 Need Custom FPGA/VHDL Work?

**Hire me for:**
- **Any FPGA & VHDL project** (design, implementation, optimization)
- **FPGA optimization & synthesis**
- **Practical VHDL training** (workshops / private classes) - in-person or online (Farsi/English)

**Email:** mahyar.mohebnia.jahromi@gmail.com  
**Telegram:** [t.me/mahyar_mohebnia](https://t.me/mahyar_mohebnia)

-----------------------------

# نمونه‌های استفاده صحیح از TextIO در VHDL
این مخزن شامل **نمونه‌کدهای عملی و بدون باگ** برای استفاده از `std.textio` در VHDL است.  
تمرکز روی الگوهای درست برای خواندن فایل‌های متنی در شبیه‌سازی است، مخصوصاً مواردی که نمونه‌کدهای اینترنتی معمولاً در آن‌ها مشکل دارند (مدیریت EOF، چندبارخوانی یک فایل، و خواندن چند فایل به‌صورت ترتیبی).

-------------------------------
## چه چیزهایی داخل این مخزن است؟
چهار الگوی اصلی پوشش داده شده‌اند:

- **یک فایل – یک‌بار خواندن**
- **یک فایل – چندبار خواندن**
- **چند فایل – هرکدام یک‌بار (به‌صورت ترتیبی)**
- **چند فایل – چندبار (چرخه‌های تکراری و ترتیبی)**

> نکته: این فایل‌ها و توضیحات درباره **الگوهای صحیح استفاده** است و خودِ پکیج `std.textio` را تغییر نمی‌دهد.

## ساختار فایل‌ها
- **read_once.vhd** - خواندن یک فایل، فقط یک بار
- **read_repeat.vhd** - خواندن یک فایل، چندبار (الگوی close/reopen)
- **multi_once.vhd** - خواندن چند فایل، هرکدام یک بار (به‌صورت ترتیبی)
- **multi_repeat.vhd** - خواندن چند فایل، چندبار (ترتیبی + تکرار پس از پایان آخرین فایل)

## نحوه استفاده (ModelSim / Vivado / ISE)
1. این مخزن را در مسیر دلخواه **Extract/Clone** کنید.
2. در شبیه‌ساز خود (ModelSim / Vivado / ISE) یک **پروژه جدید** بسازید.
3. فایل‌ها را به عنوان **Add Sources** به پروژه اضافه کنید.

> نکته: در رشته‌های VHDL روی ویندوز باید از بک‌اسلش دوتایی استفاده کنید، مثل: `D:\\project\\new106\\data1.txt`  
> و حتماً این مسیرها را داخل فایل‌های نمونه مطابق مسیر سیستم خودتان اصلاح کنید.

## کدام فایل را باید استفاده کرد؟
- می‌خواهید **یک فایل را فقط یک بار** بخوانید → `examples/read_once.vhd`
- می‌خواهید **همان فایل را چندبار** بخوانید → `examples/read_repeat.vhd`
- می‌خواهید **چند فایل را پشت سر هم (هرکدام یک بار)** بخوانید → `examples/multi_once.vhd`
- می‌خواهید **چند فایل را پشت سر هم و به‌صورت تکرارشونده** بخوانید → `examples/multi_repeat.vhd`

## نکات برای جلوگیری از باگ‌های رایج TextIO
- `endfile(fptr)` را درست مدیریت کنید تا حلقه بی‌نهایت ایجاد نشود.
- هنگام جابجایی بین فایل‌ها، فایل‌ها را درست **close** کنید.
- برای چندبارخوانی یک فایل، از الگوی **close/reopen** استفاده کنید (روی وجود “rewind” در همه ابزارها حساب نکنید).
- مسیر فایل‌ها را یکجا (مثلاً به شکل constant) نگه دارید تا تغییرشان راحت باشد.

## 📞 انجام پروژه یا آموزش FPGA/VHDL

**می‌توانید برای موارد زیر با من در ارتباط باشید:**
- **انجام هر پروژه FPGA و VHDL** (طراحی، پیاده‌سازی، بهینه‌سازی)
- **بهینه‌سازی و سنتز FPGA**
- **آموزش عملی و تخصصی VHDL** (کارگاه آموزشی / کلاس خصوصی) - حضوری یا آنلاین (فارسی/انگلیسی)

**ایمیل:** mahyar.mohebnia.jahromi@gmail.com 
**تلگرام:** https://t.me/mahyar_mohebnia
