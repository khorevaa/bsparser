﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отмена, СтандартнаяОбработка)
	
	Если СтрНайти(СтрокаСоединенияИнформационнойБазы (), "File=") = 0 Тогда 
		Сообщить("Только для файловых баз");	
	КонецЕсли;
	
	Вывод = "Дерево";

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Cancel)
	
	УстановитьВидимостьЭлементов(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура КомандаВыполнить(Command)
	
	Результат.Очистить();
	ОчиститьСообщения();
	ВыполнитьНаСервере();

КонецПроцедуры

&НаСервере
Процедура ВыполнитьНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	
	Парсер = ВнешниеОбработки.Создать(ФайлОбработки.Путь + "ПарсерВстроенногоЯзыка.epf", Ложь);
	
	Начало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если Вывод = "NULL" Тогда 
		
		Попытка 
			Парсер.Разобрать(Исходник.ПолучитьТекст());		
		Исключение 
			Сообщить("ошибка синтаксиса!");		
		КонецПопытки;	
	
	ИначеЕсли Вывод = "АСД" Тогда 
		
		Попытка 
			Модуль = Парсер.Разобрать(Исходник.ПолучитьТекст());		
		Исключение 
			Сообщить("ошибка синтаксиса!");		
		КонецПопытки;
		
		Если Модуль <> Неопределено Тогда 
			ЗаписьJSON = Новый ЗаписьJSON;
			ЗаписьJSON.SetString(Новый ПараметрыЗаписиJSON(, Chars.Tab));
			Если ПоказыватьКомментарии Тогда 
				Комментарии = Новый Соответствие;
				Для Каждого Элемент Из Модуль.Комментарии Цикл 
					Комментарии[Формат(Элемент.Ключ, "NZ=0; NG=")] = Элемент.Значение;				
				КонецЦикла;
				Модуль.Комментарии = Комментарии;			
			Иначе 
				Модуль.Удалить("Комментарии");			
			КонецЕсли;
			ЗаписатьJSON(ЗаписьJSON, Модуль, , "КонвертироватьЗначениеJSON", ЭтотОбъект);
			Результат.УстановитьТекст(ЗаписьJSON.Закрыть());		
		КонецЕсли;	
	
	ИначеЕсли Вывод = "Дерево" Тогда 
		
		Попытка 
			Модуль = Парсер.Разобрать(Исходник.ПолучитьТекст());		
		Исключение 
			Сообщить("ошибка синтаксиса!");		
		КонецПопытки;
		
		Если Модуль <> Неопределено Тогда 
			ЗаполнитьДерево(Модуль);		
		КонецЕсли;	
	
	ИначеЕсли Вывод = "Плагины" Тогда 
		
		Попытка 
			Модуль = Парсер.Разобрать(Исходник.ПолучитьТекст());		
		Исключение 
			Сообщить("ошибка синтаксиса!");		
		КонецПопытки;
		
		Если Модуль <> Неопределено Тогда 
			СписокПлагинов = Новый Массив;
			Для Каждого Строка Из Плагины.НайтиСтроки(Новый Структура("Выкл", Ложь)) Цикл 
				СписокПлагинов.Добавить(ВнешниеОбработки.Создать(Строка.Путь, Ложь));			
			КонецЦикла;
			Парсер.Подключить(СписокПлагинов);
			Парсер.Посетить(Модуль);
			МассивРезультатов = Новый Массив;
			Для Каждого Плагин Из СписокПлагинов Цикл 
				МассивРезультатов.Добавить(Плагин.Закрыть());			
			КонецЦикла;
			Результат.УстановитьТекст(СтрСоединить(МассивРезультатов));		
		КонецЕсли;	
		
	ИначеЕсли Вывод = "Бакенд" Тогда 
		
		Попытка 
			Модуль = Парсер.Разобрать(Исходник.ПолучитьТекст());		
		Исключение 
			Сообщить("ошибка синтаксиса!");		
		КонецПопытки;
		
		Если Модуль <> Неопределено Тогда 
			Бакенд = ВнешниеОбработки.Создать(ПутьБакенда, Ложь);			
			Бакенд.Инициализировать(Парсер);
			Результат.УстановитьТекст(Бакенд.Посетить(Модуль));		
		КонецЕсли;	
		
	ИначеЕсли Вывод = "Токены" Тогда 
		
		Токены.Загрузить(Парсер.Токенизировать(Исходник.ПолучитьТекст()).Токены);	
	
	КонецЕсли;
	
	Если ЗамерВремени Тогда 
		Сообщить(СтрШаблон("%1 сек.", (ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало) / 1000));	
	КонецЕсли;
	
	Ошибки.Загрузить(Парсер.Ошибки());

КонецПроцедуры

&НаСервере
Функция ЗаполнитьДерево(Модуль)
	ДеревоУзлов = Дерево.ПолучитьЭлементы();
	ДеревоУзлов.Очистить();
	СтрокаДерева = ДеревоУзлов.Добавить();
	СтрокаДерева.Имя = "Модуль";
	СтрокаДерева.Тип = Модуль.Тип;
	СтрокаДерева.Значение = "<...>";
	ЗаполнитьУзел(СтрокаДерева, Модуль);
КонецФункции

&НаСервере
Функция ЗаполнитьУзел(СтрокаДерева, Узел)
	Перем Место;
	Если Узел.Свойство("Место", Место) И ТипЗнч(Место) = Тип("Структура") Тогда 
		СтрокаДерева.НомерСтроки = Место.НомерПервойСтроки;
		СтрокаДерева.Позиция = Место.Позиция;
		СтрокаДерева.Длина = Место.Длина;	
	КонецЕсли;
	ЭлементыДерева = СтрокаДерева.ПолучитьЭлементы();
	Для Каждого Элемент Из Узел Цикл 
		Если Элемент.Ключ = "Место"
		Или Элемент.Ключ = "Тип" Тогда 
			Продолжить;		
		КонецЕсли;
		Если ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			СтрокаДерева.Тип = СтрШаблон("Массив (%1)", Элемент.Значение.Количество());
			СтрокаДерева.Значение = "<...>";
			ЭлементыСтроки = СтрокаДерева.ПолучитьЭлементы();
			Индекс = 0;
			Для Каждого Элемент Из Элемент.Значение Цикл 
				СтрокаДерева = ЭлементыСтроки.Добавить();
				Индекс = Индекс + 1;
				СтрокаДерева.Имя = Индекс;
				Если Элемент = Неопределено Тогда 
					СтрокаДерева.Значение = "Неопределено";				
				Иначе 
					Элемент.Свойство("Тип", СтрокаДерева.Тип);
					СтрокаДерева.Значение = "<...>";
					ЗаполнитьУзел(СтрокаДерева, Элемент);				
				КонецЕсли;			
			КонецЦикла;		
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Структура") Тогда 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			СтрокаДерева.Тип = Элемент.Значение.Тип;
			СтрокаДерева.Значение = "<...>";
			ЗаполнитьУзел(СтрокаДерева, Элемент.Значение);		
		Иначе 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			СтрокаДерева.Значение = Элемент.Значение;
			СтрокаДерева.Тип = ТипЗнч(Элемент.Значение);		
		КонецЕсли;	
	КонецЦикла;
КонецФункции

&НаСервере
Функция КонвертироватьЗначениеJSON(Свойство, Значение, Другое, Отмена) Экспорт
	Если Значение = Null Тогда 
		Возврат Неопределено;	
	КонецЕсли;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьЭлементов(ЭтотОбъект)
	
	Элементы = ЭтотОбъект.Элементы;
	
	Элементы.СтраницаПлагины.Видимость = (ЭтотОбъект.Вывод = "Плагины");
	Элементы.ПоказыватьКомментарии.Видимость = (ЭтотОбъект.Вывод = "АСД");
	Элементы.СтраницаРезультатДерево.Видимость = (ЭтотОбъект.Вывод = "Дерево");
	Элементы.СтраницаРезультатТекст.Видимость = (
		ЭтотОбъект.Вывод = "Плагины"
		Или ЭтотОбъект.Вывод = "АСД"
		Или ЭтотОбъект.Вывод = "Бакенд"
	);
	Элементы.ПутьБакенда.Видимость = (ЭтотОбъект.Вывод = "Бакенд"); 
	Элементы.СтраницаРезультатТокены.Видимость = (ЭтотОбъект.Вывод = "Токены");	

КонецПроцедуры

&НаКлиенте
Процедура ВыводПриИзменении(Item)
	
	УстановитьВидимостьЭлементов(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ПлагиныПутьНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьПуть(Элемент, ЭтотОбъект, РежимДиалогаВыбораФайла.Открытие, "(*.epf)|*.epf");

КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПуть(Элемент, Форма, РежимДиалога = Неопределено, Фильтр = Неопределено) Экспорт
	
	Если РежимДиалога = Неопределено Тогда 
		РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога;	
	КонецЕсли;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалога);
	ДиалогВыбораФайла.МножественныйВыбор = Ложь;
	ДиалогВыбораФайла.Фильтр = Фильтр;
	Если РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога Тогда 
		ДиалогВыбораФайла.Каталог = Элемент.ТекстРедактирования;	
	Иначе 
		ДиалогВыбораФайла.ПолноеИмяФайла = Элемент.ТекстРедактирования;	
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("Элемент, Форма", Элемент, Форма);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборФайла", ЭтотОбъект, ДополнительныеПараметры);
	
	ДиалогВыбораФайла.Show(ОписаниеОповещения);

КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборФайла(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда 
		ИнтерактивноУстановитьЗначениеЭлементаФормы(
			Результат[0], 
			ДополнительныеПараметры.Элемент, 
			ДополнительныеПараметры.Форма
		);	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИнтерактивноУстановитьЗначениеЭлементаФормы(Значение, Элемент, Форма) Экспорт
	
	ВладелецФормы = Форма.ВладелецФормы;
	ЗакрыватьПриВыборе = Форма.ЗакрыватьПриВыборе;
	
	Форма.ВладелецФормы = Элемент;
	Форма.ЗакрыватьПриВыборе = Ложь;
	
	Форма.ОповеститьОВыборе(Значение);
	
	Если Форма.ВладелецФормы = Элемент Тогда 
		Форма.ВладелецФормы = ВладелецФормы;	
	КонецЕсли;
	
	Если Форма.ЗакрыватьПриВыборе = Ложь Тогда 
		Форма.ЗакрыватьПриВыборе = ЗакрыватьПриВыборе;	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ДеревоВыбор(Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	СтрокаДерева = Дерево.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если СтрокаДерева.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(СтрокаДерева.Позиция, СтрокаДерева.Позиция + СтрокаДерева.Длина);
		ТекущийЭлемент = Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТокеныВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Строка = Токены.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + Строка.Длина);
		ТекущийЭлемент = Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПлагиныПутьОткрытие(Item, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьФайл(Элементы.Плагины.ТекущиеДанные.Путь);
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьФайл(ПолноеИмя) Экспорт
	Если ПолноеИмя <> Неопределено Тогда 
		BeginRunningApplication(
			Новый ОписаниеОповещения("ОбработатьПоказатьФайл", ЭтотОбъект, ПолноеИмя), 
			"explorer.exe /select, " + ПолноеИмя
		);	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьПоказатьФайл(ReturnCode, ПолноеИмя) Экспорт
 // silently continue
КонецПроцедуры

&НаКлиенте
Процедура ОшибкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Строка = Ошибки.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + 1);
		ТекущийЭлемент = Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПутьБакендаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьПуть(Элемент, ЭтотОбъект, РежимДиалогаВыбораФайла.Открытие, "(*.epf)|*.epf");
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьБакендаОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьФайл(Элементы.Плагины.ТекущиеДанные.Путь);
КонецПроцедуры
