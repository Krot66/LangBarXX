[GitHub](https://github.com/Krot66/LangBarXX)                   [Ветка форума Ru.Board](http://forum.ru-board.com/topic.cgi?forum=5&topic=50256#1  "28.06.2019  21:32")

**LangBar++** - *индикация раскладки у курсора и ее исправление в набранном тексте*

Представляет собой замену языковой панели, индикатор языка ввода возле текстового курсора и средство исправления раскладки введенного текста - замену Punto Switcher для тех, кто в силу ряда причин не может пользоваться автоматическим переключением, а его возможности ручного исправления кажутся неудовлетворительными. Плюс функциональное средство для тех, кто работает с большим количеством языков ввода.

Возможности:

- Иконка в трее настраиваемых пропорций в виде флага с отрисовкой на ней состояния кнопок NumLock и ScrollLock
- Флажок раскладки около текстового курсора, практически во всех приложениях, с настраиваемым размером, положением, прозрачностью и индикацией состояния CapsLock
- Неподвижный, прозрачный для кликов индикатор раскладки с отображением тех же трех клавиш, полностью настраиваемым видом, положением и отображением в выбранных программах
- Иконка, флажок и индикатор генерируются из png-файлов, которые легко заменить вручную; их отрисовка возможна для любых раскладок клавиатуры
- Ручное исправление раскладки набранного или выделенного текста. В отличие от Punto Switcher, происходит не простое преобразование последнего слова, а выделение набранных слов одно за другим слов с небольшой задержкой, так что и печатая не отрывая глаз от клавиатуры можно потом исправить все
- Преобразование не ограничено парой языков английский-русский -  можно работать с множеством языков, используемых системой, и набранный текст будет всегда преобразуем меж ними
- Возможность использования посимвольного выделения, позволяющего останавливать его посреди слова, что часто необходимо, например, в программировании
- Преобразование регистра (в заглавные буквы, строчные, заглавные первые или его инверсия), а также транслитерации с использованием того же  механизма быстрого выделения или выделенного вручную
- Поддержка FAR, ConEmu и командной строки; ограниченная (не отображается флажок) терминала Windows 11
- Настройка клавиш CapsLock, NumLock, ScrollLock, активизация языков ввода левыми и правыми клавишами Ctrl и Shift

Программа адаптирована к использованию на виртуальных машинах, отличается высокой совместимостью и низким потреблением системных  ресурсов. Может использоваться в качестве индикатора раскладки для слабовидящих.

Идет в одном исполняемом файле, осуществляющем установку и распаковку портативной версии.

**Операционная система**: Windows XP - 11

### Флажок раскладки и его настройка

<img src="ReadMe.assets/ReadMe1.gif" alt="ReadMe2" style="zoom:60%;" />

Отражается в полях текстового ввода - там, где имеется текстовый курсор. Имеется возможность менять относительное положение флажка мышью или масштабировать его колесиком, все с зажатым *Shift*. Можно менять прозрачность флажка прокручивая над ним колесико с зажатым *Alt* (*Alt+средняя кнопка* - значок непрозрачен). Настройки флажка всегда можно сбросить щелкнув по значку средней кнопкой мыши с зажатым *Shift*.

> Если у вас плохое зрение, можно попробовать разместить увеличенный флажок ниже курсора, где он не будет мешать. Минусами данного способа является то, положение флажка будет зависеть от используемого размера шрифта, а при использовании горизонтального курсора, как в командной строке, флажок будет смещаться ниже

Состояние *CapsLock* отображается на флажке в виде голубой тени, хорошо заметной на светлом и темном фоне. 

> Значок можно всегда быстро выключить или включить одновременным нажатием левого и правого *Shift* или из меню.

Пункт меню *Настройка флажка* предназначен для быстрой настройки его на ноутбуках и планшетах, где мышь отсутствует:

<img src="ReadMe.assets/ReadMe1.png" alt="ReadMe1" style="zoom: 60%;" />

### Значок в трее, состояние NumLock и ScrollLock

Однократное нажатие на флажок или иконку в трее левой кнопкой мыши меняет раскладку. Состояние *NumLock* и *ScrollLock* отображается в виде двух цветных глаз на иконке в трее, флажок на которой при этом смещается вниз. Если вы привыкли работать с включенным NumLock, можно отметить в настройках пункт "Включен по умолчанию". В этом случае включение *NumLock* будет соответствовать неизменной иконке, и клавиша будет автоматически нажиматься при запуске программы.

### Индикатор раскладки

Дает ту же картинку, что и флажок, дополненную индикаторами NumLock и ScrollLock, как на иконке в трее, которая может быть неподвижно поставлена в любом месте. Для его включения и выключения используется сочетание  *Ctrl+Shift+Shift* (Ctrl слева или справа). Поскольку индикатор прозрачен для кликов, настраивать его можно только с помощью панели, вызываемой из меню *Индикатор*. Она подобна той, с помощью которой можно настраивать флажок, только лишена текстового поля:

<img src="ReadMe.assets/ReadMe2.png" alt="ReadMe2" style="zoom: 60%;" />

В статусной строке отображаются текущие параметры отображения, при этом положение и размер выражены в процентах к размеру экрана, что дает независимость отображения индикатора при переносе портативной программы на другой компьютер. Кнопки определения положения работают с повторениями при их зажатии, так что все делается достаточно быстро. Пока открыто окно настроек, можно использовать курсорные клавиши для определения положения и те же курсорные клавиши с зажатым *Ctrl* для изменения прозрачности и размера. 

Индикатор всегда выключен если активным окном являются рабочий стол или панель задач.

#### Правила приложений

Постоянно включать и выключать индикатор не слишком удобно, поэтому предусмотрена настройка приложений, где он виден или, наоборот, не виден. Если нажать то же сочетание *Ctrl+Shift+Shift* и удержать его секунду, появится окно правил (его можно вызывать и из меню *Индикатор*) с подсветкой правила для текущего окна, если оно есть, или тултипом *Нет включенных правил для данного приложения!*:

<img src="ReadMe.assets/ReadMe3.png" alt="ReadMe3" style="zoom: 60%;" />

Вверху имеется кнопка *Для создания правила перетащите кнопку на окно приложения*, и прежде, чем разбираться с содержимым окна, создадим правило для текущего приложения. Перетаскиваем кнопку на окно и получаем окошко примерно такого содержания:

<img src="ReadMe.assets/ReadMe4.png" alt="ReadMe4" style="zoom: 60%;" />

Здесь под именем файла понимается исполняемый файл, связанный с окном приложения. Класс окна - это особая его характеристика, здесь используемая для точности работы и исключения ошибок при совпадении имен файлов. Например, все окна современных приложений имеют класс *ApplicationFrameWindow*, а почти все браузеры и приложения, сделанные на основе Chrome, имеют класс *Chrome_WidgetWin_1*. Последнее поле отображает описание файла, если оно есть (то самое, что видно на последней вкладке свойств файла в проводнике); туда же можно вписать произвольный комментарий. Наконец имеется кнопка *Все!*, с нажатием на которую вместо имени файла будет подставлена маска \*.\*, означающая, что все окна данного класса, имеющие разные исполняемые файлы, будут обрабатываться данным правилом. Следует иметь ввиду, что не все окна имеют класс, и при его отсутствии, создание таких универсальных правил блокируется программой. 

Наконец, ниже идут круглые радиокнопки *Всегда включен* и *Всегда выключен*, соответствующие тому, что индикатор появляется в окне, даже если он выключен, или отсутствует, даже если он включен. Очевидно, есть две политики настройки программы: держать индикатор постоянно включенным, добавляя программы исключения, и постоянно выключенным, включая его в нужных приложениях; вам следует выбрать наиболее подходящую.

Теперь можно вернуться к исходному окну и тому, как оно отображает существующие правила. В первой колонке идет его номер и чекбокс, с помощью которого можно его выключить. Затем идет колонка +/-, соответствующая тому, всегда включен или выключен индикатор для данного окна. Далее идут колонки, которые мы видели в окне создания правил. Программа идет с полдюжиной готовых правил для терминала Windows, где пока флажок не отображается, и нескольких плееров, где появление индикатора нежелательно. Следует обратить внимание, что звездочка может использоваться в именах файлов и для обозначения фрагментов имени, как это сделано в правилах для MPC, где она заменяет возможный суффикс `64` для 64-разрядной версии программы.

Ниже списка правил размещена кнопка *Редактировать*, с помощью которой можно открыть то же окно, в котором правила создавались (его можно вызвать двойным щелчком мыши по правилу), и кнопки *Вверх, Вниз*. Когда программа считывает правила, существующие для данного приложения, она делает это сверху вниз до нахождения первого подходящего и включенного, с поставленной галкой. Поэтому если вы создали универсальное правило для окон определенного класса, но хотите выделить из него одну программу, под него подпадающую, следует создать для нее правило и поставить его выше!

### Исправление раскладки

<img src="ReadMe.assets/ReadMe2.gif" alt="ReadMe2" style="zoom:60%;" />

Преобразование текста производится нажатием кнопки *Pause/Break* или правым щелчком по флажку индикатора раскладки. Причем конвертировать возможно не только последнее набранное слово: если оставить на короткое время клавишу зажатой, будет выделено и преобразовано предыдущее, если только не производилось переключение раскладки, манипуляции мышью и нажатия нетекстовых клавиш, говорящие об окончании непрерывного ввода. Тем же способом можно конвертировать и выделенный текст. Оба вида работают при наборе текста внутри строки. 

<img src="ReadMe.assets/ReadMe3.gif" alt="ReadMe3" style="zoom:60%;" />

Преобразование работает в FAR, ConEmu, командной строке и терминале Windows 11, при этом из-за особенностей программ происходит забивание символов вместо их выделения. Можно всегда использовать этот абсолютно совместимый способ, например, в очень старых приложениях, с помощью сочетания *Shift+Backspace* вместо *Pause*. 

#### Посимвольное выделение

<img src="ReadMe.assets/ReadMe4.gif" alt="ReadMe4" style="zoom:60%;" />

Помимо быстрого выделения "по словам", программа предусматривает возможность посимвольного выделения (включаемого в соответствующем пункте настроек), полезного, например, в программировании, когда вводятся текстовые значения функций. Для этого сначала посылается короткое нажатие клавиши Pause; при последующем ее нажатии будет происходить посимвольное выделение набранного текста, пока клавиша нажата, и преобразование при ее отпускании. 

> Соответственно, при отсутствии отпускания будет производиться обычное выделение по словам, только начинающееся после почти незаметной задержки. 

Это работает и в случае использования *Shift+Backspace* - в этом случае *Shift* остается зажатым, а производится быстрый клик и зажатие *Backspace*.

Возможно и комбинированное выделение: первое слово или несколько слов выделяется длинным нажатием клавиши, затем отпускание клавиши и повторное нажатие с посимвольным выделением. В случае прерванного выделения по словам до преобразования будет небольшая задержка (смотри ниже). Можно избежать ее, отметив опцию *Только с начала*.
Посимвольное выделение работает и при использовании флажка, который в этом случае будет оставаться под курсором мыши.

Преобразование текста всегда производится после отпускания клавиши!

#### Настройка задержек выделения

Поскольку способности к печати и разбитость клавиатуры у всех разная,  в программу зашиты некие усредненные и общеприемлемые величины задержек, но сделано возможным корректировать их вручную в графическом интерфейсе, вызываемом из меню настроек:

<img src="ReadMe.assets/ReadMe5.png" alt="ReadMe5" style="zoom: 60%;" />

Здесь:

- Интервал выделения по словам - промежуток времени, который программа ждет прежде, чем выделить следующее слово
- Ожидание отпускания клавиши - время, которое программа ждет отпускания клавиши (посимвольное выделение) до начала выделения по словам
- Интервал посимвольного выделения - интервал выделения символов при посимвольном выделении

В случае перехода с выделения по словам на посимвольное выделение, программа ждет половину значения последней задержки отпускания клавиши, и еще столько же ее повторного нажатия.

#### Настройки переключения и исправления раскладок

Если нажать в меню на пункт *Раскладки и флажки*, появмится соответствующее окно:

<img src="ReadMe.assets/ReadMe6.png" alt="ReadMe6" style="zoom:60%;" />

В верхней его части отображается список используемых системой раскладок с иконками флажков и именами соответствующих файлов изображений. Код раскладки приводится для ориентировки, он соответствует тому, с которым работает система.

Ниже, в разделе *Переключение раскладки*, можно задать из выпадающих меню языки ввода, активирующиеся при отдельном нажатии на левые и равые кнопки Ctrl и Shift. Следующий чекбокс позволяет предотвратить падения и зависания программ (например, 3DS Max и VNote), связанные с посылкой сообщений Post- или SendMessage, как это делают все программы и скрипты данного класса. Он чуть медленнее стандартного, но совершенно совместим и исключает возможные трудности. Это работает при всех переключениях или исправлениях раскладки и устанавливается по умолчанию.

Приведенные выше сочетания *Pause* и *Shift+Backspace* изначально работают только с русской и английской раскладкой - они игнорируются при любом другом языке ввода. Клавиши можно выключить или переопределить для других пар языков, если воспользоваться выпадающим меню в разделе *Исправление раскладки* окна.

Кроме того, можно обменять функции клавиши *Pause* и сочетания *Shift+Backspace*, отметив соответствующий чекбокс, что сделано для ноутбуков, часто имеющих скрытую клавишу *Pause,* повешенную на сочетание с клавишей *Fn.* При этом сочетание *Shift+Backspace* будет работать с видимым выделением вместо забоя (кроме требующих этого приложений), настройки же раскладок в выпадающем меню сохранятся. 

#### Работа с множественными раскладками

В программе предусмотрена работа с тремя и более раскладками с возможностью преобразования текста меж ними, что, очевидно, требует набора клавиш, связанных с каждой из них. В том же окне *Раскладки и флажки* языки ввода отображаются так же, как в панели управления, и каждой из них присвоен номер, который можно изменить, поменяв последовательность языков в панели управления, нажав кнопку *Языки (ПУ)* (после следует перезапустить программу или нажать кнопку *Обновить* для применения изменений). 

> В ранних версиях Windows можно поменять лишь язык, стоящий на первом месте с помощью выпадающего меню вверху окна. В любом случае, следует ориентироваться только на нумерацию языков в окне программы.
> Еще: Windows крайне криво работает с добавлением и удалением языков ввода, и новые версии не лучше прежних. Не поленитесь выйти из системы, чтобы все работало корректно.

Имеется возможность использовать для номера целевой раскладки, к которой будет преобразован текст, два набора клавиш, которые включаются соответствующими чекбоксами: цифровые клавиши основной клавиатуры и расположенные над ними функциональные клавиши F*. Так что первой раскладке соответствуют целевые клавиши *1* и *F1*, второй *2* и *F2*, и т. д.. 

Действуют следующие сочетания клавиш:

- Правый *Ctrl + целевая клавиша* - исправление раскладки стандартным способом, через выделение (как *Pause*)
- Правый *Shift + целевая клавиша* - исправление раскладки через забивание (как *Shift+Backspace*)
- Правый *Alt + целевая клавиша* - переключение раскладки

Работа с клавишами осуществляется так же, как в рассмотренных выше случаях, посимвольное выделение работает и здесь. Основное отличие касается обработки выделенного текста, для интерпретации которого текущая раскладка должна совпадать с раскладкой набранного текста. Если использовались клавиши Pause, Shift+Backspace, CapsLock и правое нажатие на флажок, будет автоматически произведена попытка (в случае двух языков всегда успешная) переключения языка на второй, им назначенный, при неудаче появится тултип “Неверная раскладка!”. После ручного изменения раскладки, все должно стать на свои места. Как и в случае кнопки *Pause*, при работе с командной строкой и терминалом, будет автоматически использоваться совместимый режим (правый Shift вместо правого Ctrl).

#### Обработка Backspace, табуляций и переносов

Программа автоматически учитывает нажатие клавиши *Backspace* и они не является помехой для преобразования текста. По умолчанию, табуляции и переводы строки рассматриваются как знаки начала новой записи текста. В обычных условиях это оправдано: вам ни к чему, чтобы выделение заходило на предыдущий абзац или предыдущую колонку. Программа имеет возможность корректной обработки табуляций и переводов строки, и этим можно воспользоваться, например, если вы вводите текст с большим количеством жестких переносов или табуляций. Чтобы это сделать, отметьте соответствующие пункты в меню *Выделение*.

>   В случае использования редактора, не позволяющего выделению по *Shift+Left* переходить на предыдущую строку (для чего предполагается использование *Shift+Up*), следует использовать сочетание *Shift+Backspace!*
>   Отработка табуляций не работает в редакторах, где они автоматически заменяется кратными пробелами (проверить можно включив отображение непечатаемых символов).

К преимуществам *Shift+Backspace* можно отнести и то, что если в редакторе включена подсветка сходных мест, выделение фрагментов текста с включенной обработкой переносов может работать некорректно.

### Преобразование регистра набранного текста

Производится подобно исправлению раскладки, настройки выделения действуют и здесь. Сочетания действуют и для выделенного текста. 
Горячие клавиши:

- Правый `Ctrl+=` - инверсия регистра
- Правый `Ctrl+-` - в нижний регистр
- Правый `Ctrl+0` - в верхний регистр
- Правый `Ctrl+9` - первые заглавные

Для посимвольного выделения надо зажимать правый Ctrl и манипулировать основной клавишей.

Инверсию регистра можно производить и нажатием средней кнопки по флажку.  Это работает как с выделенным текстом, так и с выделением при нажатии на флажок, который при этом остается на месте.

В настройках есть опция использования CapsLock только в качестве клавиши инверсии регистра, но еще есть и возможность сохранить при этом ее основной функционал (пункт *То же и инверсия регистра*). При этом основной функционал клавиши сохраняется, а выделение или преобразование выделенного текста начинаются только после небольшой (0.3 c) задержки. Посимвольное выделение при этом не действует!

Как и в случае исправления раскладки, преобразование производится после отпускания клавиши. После всех изменений регистра CapsLock находится в выключенном состоянии. Изменения регистра производятся при любых раскладках клавиатуры.

### Транслитерация текста

Возможна транслитерация набранного и выделенного текста. Работает по тем же принципам, что и исправление раскладки и изменение регистра. Используется "стандартная таблица" транслитерации (ГОСТ 7.79-2000). 

Для этого используется сочетание:  Правый `Ctrl+]`.

### Особенности работы в браузерах

Современные браузеры не являются стандартным приложением Windows - по сути, это большая веб-страница, на которой нарисован интерфейс и ее содержимое. Получить положение курсора в ней можно (и то не всегда), получить же положение полос прокрутки невозможно в принципе. Поэтому при прокрутке мышью, тачпадом или масштабировании страницы флажок начинает "плыть", уходя от положения курсора. Чтобы исправить это, в программе сделано так: флажок при начале прокрутки исчезает и появляется вновь, когда снова находит позицию курсора, в том числе при нажатии левой кнопки мыши или текстовом вводе. 

Поддерживаются следующие браузеры: 

- Firefox Quantum (57+) и браузеры на его основе
- Chrome и хромоклоны (Edge, Opera, Maxthon, Vivaldi, Brave, SlimJet и др., плюс приложения Google Electron)
- "Старики" Internet Explorer и Opera Presto

### Работа с FAR, ConEmu, командной строкой и терминалом

При их использовании автоматически производится забивание символов вместо выделения при использовании всех горячих клавиш. Флажок в командной строке и FAR на Windows 10  появляется только при включении режима старой командной строки  (*Свойства - Настройки - Использовать прежнюю версию консоли*). На Windows 11 уже и FAR запускается из терминала, поэтому чтобы видеть флажок в нем и командной строке, надо зайти в его настройки и выбрать в *Startup - Default Terminal Application Windows Console Host*.
Отображение флажка в терминале Windows 11 невозможно, по крайней мере сейчас, в остальном все работает так же, как и в командной строке. ConEmu является наиболее беспроблемным инструментом на всех осях, позволяющим отображать флажок и преобразовывать выделенный текст.

### "Современные" (UWP) приложения

Отображение флажка не работает из-за все той же неопределимости положения каретки (как в терминале Windows, который той же породы), но преобразование раскладки работает, причем любым способом, включая Pause и сочетания Ctrl+1/F1 и пр..

### Использование на виртуальных машинах

Программа сделана так, что при запуске VirtualBox или VMware Player запущенная на хосте версия автоматически отключается и не препятствует работе программы, запущенной на виртуальной машине. На VMware Player работают все сочетания исправления раскладки, на VirtualBox можно использовать сочетание *Shift+Backspace* для исправления раскладки, *CapsLock* для инверсии регистра, исправления или переключения раскладки. Если в окне *Раскладки и флажки* отметить опцию *Обменять назначение кнопок Pause и Shift+Backspace*, по последнему сочетанию будет работать выделение текста и на VirtualBox.
Клавиши работы с множественными раскладками (Shift+1/F1…) и клавиши вызова раскладок (Alt+1/F1…) должны работать на виртуальных машинах. Как правило, на обоих типах виртуальных машин исправно работает флажок. Из клавиш “назначенного” переключения (левые и правые Ctrl и Shift) в VirtualBox не работает правый Ctrl, являющийся “хост” клавишей, но можно в этом качестве использовать правый Shift.

### Замена флажков и визуальных элементов

Как было сказано, флажки раскладок отображаются все в том же окне *Раскладки и флажки.* Все флаги находятся в каталоге *flags* программы и должны соответствовать короткому имени раскладки в [Microsoft Windows LCID List](https://www.ryadel.com/en/microsoft-windows-lcid-list-decimal-and-hex-all-locale-codes-ids/). Если язык ввода редок и не входит в официальный перечень, будет использоваться имя из цифрового кода раскладки. Когда программа не находит флажка для вашей текущей раскладки в каталоге *flags*, поле рядом с номером, раскладка в трее и на флажке будет отображаться в виде вопросительного знака с фоном одного из трех цветов - синего, зеленого и красного (файлы 1.png, 2.png и 3.png в каталоге flags - можно добавить еще, если нужно, без этого они будут чередоваться). Для добавления можно использовать имеющийся в каталоге *flags* архив с флажками или найти нужное где-то еще, переименовать как требуется, поместить в каталог *flags*, и, собственно, все - работать начнет сразу же.

Общие требования к файлам флажков:

- Формат png
- Отсутствие прозрачных полей, почти всегда имеющихся у выложенных в сети флажков (в флажках в архиве они удалены пакетной обработкой)
- Не слишком большой размер, обработка которого не влияет на ресурсы компьютера (штатные флажки имеют размер ~64 px)

Пропорции значка не имеют значения и меняются программой.

Кроме того:

- Нежелательно использование "объемных" флажков с тенями и пр. - простые, плоские значки в большинстве случаев выглядят лучше
- Предпочтительно использование упрощенных флажков без излишней деталировки; часто имеет смысл оставить центральную, значимую часть и обрезать остальное
- Небольшое размытие может улучшать отображение сложных флажков
- Крупные скругленные углы могут быть видны на подложке флажка при большом его размере

В каталоге *masks* есть три файла, накладывающихся на иконку в трее для обозначения состояния клавиш *NumLock* и *ScrollLock*. Названия двух из них соответствуют этим кнопкам, еще есть файл *NumScroll.png*, соответствующий случаю, когда отображение одной из кнопок отключено. Все файлы квадратного размера, что обязательно, и, большей частью, прозрачны. Их можно перерисовать заново или изменить размеры непрозрачной части, но заниматься этим стоит в основном в случае, если вы либо имеете высокий DPI системы, либо флаг страны в иконке вас вообще мало интересуют. 

Когда иконка меняется для отображения состояния кнопок, флаг смещается вниз чтобы остаться видимым и не быть полностью заслоненной масками. Это поведение можно изменить, поменяв параметр *Icon_Shift* в *LangBarXX.ini*. Значению `-1` будет соответствовать сдвиг иконки вверх, а `0` - ее неподвижность.

### Установка и обновление программы

Программа идет в одном установочном файле, откуда возможна ее инсталляция и создание переносной версии, в том числе с помощью приложенных батников тихой установки и распаковки portable. 

При необходимости добавления флажков, отсутствующих в инсталляторе программы, следует создать каталог flags в папке установщика и поместить в него требуемые png-файлы, которые будут добавлены в каталог flags программы, перезаписывая существующие при совпадении имен. Точно так же можно перенести каталог masks и файл настроек LangBarXX.ini. Иначе, если у вас есть настроенная портативная версия программы, достаточно поместить в ее каталог инсталлятор и батник тихой установки для быстрого переноса ее на другой компьютер.

> При обновлении программы или распаковке портативной версии в тот же каталог, имеющиеся папки flags и masks сохраняются с суффиксом '_old', добавленные файлы флажков остаются на месте.

### FAQ

*В. Как при необходимости быстро выделить вручную, в том числе познаково, и преобразовать текст с помощью клавиатуры?*
О. Зажав Shift левой курсорной клавишей выделить текст и не отпуская его нажать BackSpace.

*В. Как убрать ставший ненужным текстовый индикатор раскладки, чтобы он не занимал место на панели задач?*
О. Панель управления - Языки - Дополнительные настройки.

*В. У меня плохо работает исправление раскладки по правому клику мыши на флажке - почему?*
О. Это может быть связано с использованием внешнего менеджера жестов мыши, использующих тот же правый клик. Для устранения проблем обычно достаточно, чтобы программа запускалась уже после него, что можно сделать с помощью скриптов, планировщика или программ, например, бесплатных Anvir Task Manager или Autorun Organizer, работающих с отложенной загрузкой.

*В. Как программа работает с дополнительными раскладками, установленными для одного языка?*
О. Программа работает с "языками ввода", а не с "методами ввода", и дополнительные раскладки не отображаются в соответствующем окне программы. Поэтому нельзя наперед предсказать ее поведение в этом случае. 

*В. Является ли портативная версия программы "silent", не оставляющей следов в системе?*
О. Да, пока не используется автозапуск.

*В. Как превратить установленную версию программы в портативную?* 
О. Достаточно скопировать каталог программы, удалить из него два файла деинсталлятора unins000.* и добавить пустой текстовый файл portable.dat (можно скопировать туда же конфигурационный файл LangBarXX.ini из %APPDATA%\LangBarXX для сохранения настроек).

*В. Иногда после выхода из спящего режима, флажок перестает реагировать на нажатия мыши или зависает - что с этим делать?*
О. Программа сделана так, что любое ручное переключение раскладки клавиатуры (по *Alt+Shift, Ctrl+Shift, Win+Space*) перезапускает ее основные потоки, поэтому достаточно простого переключения раскладки для исправления этого.

*В. Почему запущенный в песочнице (Sandboxie и пр.) браузер не отображает флажок?*
О. Взаимодействие браузера с операционной системой искусственно ограничено и получить позицию курсора невозможно.

*В. На Windows 10 или 11, в некоторых программах (AkelPad) флажок уплывает от курсора при наборе текста - что с этим делать?*
О. Скорее всего, это связано с масштабированием интерфейса свыше 100% в операционной системе. Следует задать режим совместимости для высоких разрешений в соответствующей программе (Свойства ярлыка или файла - вкладка Совместимость) - тогда все станет на свои места.

*В. Как быстро заменить на LangBar++ имеющийся индикатор раскладки (Punto или другой) в Wim- или Iso-образе загрузочного дика?*
О. Переименовать исполняемый файл LangBarXX.exe требуемым образом (при необходимости сохранения настроек - и LangBarXX.ini) и заменить им исходный, не забыв про папки и файлы программы. 

*В. Почему столько дрязг с отображением какого-то флажка, что должно быть чем-то простым и само собой разумеющимся в Windows?*
О. Данный вопрос решительно непостижим для автора программы…

### Приложение. Немного о принципе действия программы

Программа постоянно отслеживает ввод текстовых символов в виде нажатий виртуальных клавиш клавиатуры, а также клавиш Shift и CapsLock. Запись обнуляется активацией новых окон, действиями мыши и нажатиями ряда клавиш, вроде *Home, End, PgDn*, курсорных клавиш, клавиш переключения раскладки и других, говорящих о том, что непрерывный ввод текста прерван и начата новая запись. Если нажать сразу после этого клавишу исправления раскладки, появится сообщение: "Буфер пуст - выделите текст!". Когда происходит исправление текста, те же виртуальные коды после изменения раскладки посылаются как реальные нажатия клавиш - в этом и состоит все исправление текста.
Этот процесс никак не зависит от раскладки клавиатуры и происходит автоматически. Когда же преобразуется выделенный текст, возникает необходимость правильно прочитать набранные символы и преобразовать их в виртуальные коды, чтобы далее отправить их программе с измененной раскладкой. Именно поэтому преобразование выделенного текста возможно лишь в случае, если текущая раскладка соответствует набранному тексту, что и позволяет его интерпретировать верно.
Из сказанного следует, что программа не привязана к типу клавиатуры и используемым клавиатурным раскладкам, по крайней мере, в пределах вообразимого в настоящий момент.

### Использованы при разработке

- Начальный код отображения флажка [Irbis ](http://forum.script-coding.com/viewtopic.php?id=10392&p=3)

- Gdip library by Tic

- Acc Standard Library by Sean

- FileGetInfo by Lexicos

- Free Flag Icons by [GoSquared](http://www.gosquared.com)
