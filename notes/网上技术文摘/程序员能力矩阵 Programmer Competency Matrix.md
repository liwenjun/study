> 注意:每个层次的知识都是渐增的，位于层次_n_，也蕴涵了你需了解所有低于层次_n_的知识。

|计算机科学 Computer Science|   |   |   |   |
|---|---|---|---|---|
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|数据结构|不知道数组和链表的差异|能够解释和使用数组，链表，字典等，并且能够用于实际的编程任务。|了解基本数据结构时间和空间的折中，比如数组vs 链表，能够解释如何实现哈希表和处理冲突，了解优先队列及其实现。|高等的数据结构的知识，比如B-树、二项堆、斐波那契堆、AVL树、红黑树、伸展树、跳跃表以及前缀树等。||
|算法|不能够找出一个数组各数的平均值(这令人难以置信，但是我的确在应聘者中遇到过)|基本的排序，搜索和数据的遍历和检索算法。|树，图，简单的贪婪算法和分而治之算法，能够适度了解矩阵该层的含义。|能够辨识和编写动态规划方案，良好的图算法知识，良好的数值估算的知识，能够辨别NP问题等。|Working with someone who has a good topcoder ranking would be an unbelievable piece of luck!|
|编程体系|不知道何为编译器、链接器和解释器。|对编译器、链接器、解释器有基本的了解。知道什么是汇编代码以及在硬件层如何工作。有一些虚拟内存和分页知识。|了解内核模式vs用户模式,多线程，同步原语以及它们如何实现，能够阅读汇编代码。了解网络如何工作，了解网络协议和socket级别编程。|了解整个程序堆栈、硬件(CPU+内存+中断+微码)、二进制代码、汇编、静态和动态链接、编码、解释、JIT（just-in-time）编译、内存碎片回收、堆、栈、存储器编址…||
|软件工程 Software Engineering|   |   |   |   |
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|源码版本控制|通过日期备份文件夹|VSS和初级的CVS/SVN用户|熟练地使用CVS和SVN特性。知道如何分支和归并，使用程序库补丁安装特性等|有分布式VCS系统的知识。尝试过Bzr/Mercurial/Darcs/Git||
|自动化编译|只知道在IDE下编译|知道如何编译在命令行下编译系统|能够安装一个脚本构建基本的系统|能够安装一个脚本来构建系统并且归档，安装程序，生成发布记录和给源码控制中的代码分配标签。||
|自动化测试|认为所有的测试都是测试员的工作。|能够编写自动化的单元测试，能够为正在编写的代码提出良好的测试用例。|按照TDD （Test Driven Development）方式编写代码。|了解并且能够有效自动化安装，载入/性能和UI测试||
|程序设计 Programming|   |   |   |   |
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|问题分解|只有直线式的代码，通过复制粘贴来复用|能够把问题分散到多个函数中|能够想出可复用的函数/对象来解决大题的问题|使用适宜的数据结构和算法，写出通用的/面向对象的代码来封装问题的易改变的层面。||
|系统分解|N想不出比单一的文件/类更好的层面|如果不在同一平台或没采用相同的技术，能够把问题空间和设计方案分解。|能够设计跨技术/平台的系统。|能够在多个产品线和与外部体系一体化中虚拟化和设计复制的系统。同时也能够设计支持系统监视、报告、故障恢复等。||
|交流|不能向同伴表达想法/主意。匮乏拼写和语法的能力。|同伴能了解你在说什么。有良好的拼写和语法能力。|能够和同伴进行高效的交流|能够使用清晰的方式了解和交流想法/设计/主意/细则，能适应每种环境的交流|This is an often under rated but very critical criteria for judging a programmer. With the increase in outsourcing of programming tasks to places where English is not the native tongue this issue has become more prominent. I know of several projects that failed because the programmers could not understand what the intent of the communication was.|
|同一文件中代码组织|同一文件中组织没有依据|按照逻辑性或者易接近的方法|代码分块和对于其他源文件来说是易于是释,引用其他源文件时有良好的注释|文档头部有许可声明，总结，良好的注释，一致的空格缩进。文档外观美观。||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|跨文件代码组织|没够想过给代码跨文件组织|相关文件按文件夹分组|每个物理文件都有独立的目的，比如一个类的定义，一个特性的实现等。|代码在物理层组织紧密，在文件名上与设计和外观相匹配，可以通过文件分布方式洞察设计理念。||
|源码树组织|一切都放在一个文件夹内|初步地将代码分散进对应逻辑的文件夹。|没有循环依赖，二进制文件，库，文档，构建，第三方的代码都组织进合适的文件夹内。|源码树的物理布局与逻辑层次、组织方式相匹配。可以通过目录名称和组织方式洞察设计理念。|The difference between this and the previous item is in the scale of organization, source tree organization relates to the entire set of artifacts that define the system.|
|代码可读性|单音节的名称 （在国内应该是那些类似用汉语拼音命名的习惯）|对文件、变量、类、方法等，有良好的命名。|没有长函数、注释解释不常规的代码，bug修复,代码假设。|代码假设验证使用断言，自然的代码流，没有深层嵌套的条件和方法||
|防御性编码|不知道这个概念|检查代码中所有的参数，对关键的假设进行断言|确保检查了返回值和使代码失败的异常。|有自己的库来帮助防御性编程、编写单元测试模拟故障||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|错误处理|只给乐观的情形编码|基本的代码错误处理，抛出异常/生成错误|确保错误/异常留在程序中有良好的状态，资源，连接，内存都有被合适的清理。|在编码之前察觉可能出现的异常，在代码的所有层次中维持一致性的异常处理策略，提出整个系统的错误处理准则。||
|IDE|IDE大部分用来进行文本编辑|了解其周围的接口，能够高效地通过菜单来使用IDE|了解最常操作的键盘快捷键|编写自定义宏||
|API|需要频繁地查阅文档|把最频繁使用的API记在脑子里|广阔且深入的API知识。|为了使实际任务中常用API使用更加便捷，编写过API的上层库，填补API之间的缺口。|E.g. of API can be Java library, .net framework or the custom API for the application|
|框架|没有使用过主平台外的任何框架|听过但没用过平台下流行的可用框架|在专业的职位中使用过一个以上的框架，通晓各框架的特色。|某框架的作者||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|需求分析|接受给定的需求和代码规格|能对规格的遗漏提出疑问|了解全面情况，提出需要被规格化的整体范围。|能够提出更好的可选方案，根据经验的浮现给出需求||
|脚本|不具备脚本工具的知识|批处理文件/shell脚本|Perl/Python/Ruby/VBScript/Powershell|写过并且发表过可重用的代码||
|数据库|认为Excel就是数据库|知道基本的数据库概念，规范化、ACID（原子性Atomicity、一致性Consistency、隔离性Isolation、持久性Durability）、事务化，能够写简单的select语句|能够牢记在运行时必要查询中设计良好的规范化数据库模式， 精通用户视图，存储过程，触发器和用户定义类型。知道聚集与非聚集索引之间的差异。精通使用ORM（Object Relational Mapping对象关系映射）工具|能做基本的数据库管理，性能优化，索引优化，编写高级的select查询，能够使用相关sql来替换游标，理解数据内部的存储，了解如何镜像、复制数据库。知道两段数据提交如何工作||
|经验 Experience|   |   |   |   |
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|专业语言经验|命令式语言和面向对象语言|命令式语言,面向对象语言和说明型语言(SQL),如果了解静态类型vs动态类型，弱类型vs强类型则有加分|函数式语言,如果了解延缓求值，局部套用函数，延续则有加分|并发语言(Erlang, Oz) 逻辑语言(Prolog)||
|专业平台经验|1|2-3|4-5|6+||
|专业经验年龄|1|2-5|6-9|10+||
|领域知识|没有该领域的知识|在该领域中曾经至少为一个产品工作过|在同一领域中为多个产品工作过|领域专家。在该领域设计和实现数种产品/方案。精通该领域使用的标准条款和协议||
|学识 Knowledge|   |   |   |   |
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|工具知识|仅限于主要的IDE(VS.Net, Eclipse等)|知道一些流行和标准工具的备选方案|对编辑器、调试器、IDE、开源的备选方案有很好的了解。比如某人了解大多数Scott Hanselman的威力工具列表中的工具，使用过ORM工具。|实际地编写过工具和脚本，如果这些被发布则有加分||
|语言接触|命令式语言和面向对象语言|命令式语言、面向对象语言和说明型语言(SQL),如果了解静态类型vs动态类型、弱类型vs强类型则有加分|函数式语言,如果了解延缓求值、局部套用函数、continuations （源于scheme中的一种高级控制结构）则有加分|并发语言(Erlang, Oz) 逻辑语言(Prolog)||
|代码库知识|从来没有查询过代码库|基本的代码层知识，了解如果构建系统|良好的代码库工作知识，实现过几次bug修复或者完成了一些细小的特性|实现了代码库中多个大型特性，能够轻松地将多数特性的需求变更具体化，从容地处理bug修复。||
|下一代技术知识|从来没听说过即将到来的技术|听说过某领域即将到来的技术|下载过alpha preview/CTP/beta版本，并且读过一些文章和手册|试用过预览版而且实际地构建过某物，如果共享给其他人的话则有加分||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|平台内部|对平台内部毫无所知|有平台基本的内部工作的知识|深度的平台内部知识，能够设想平台如何将程序转换成可执行代码。|编写过增强平台或者为其平台内部提供信息的工具。比如，反汇编工具，反编译工具，调试工具等。||
|书籍|菜鸟系列，21天系列，24小时系列，蠢货系列...|《代码大全》，《别让我思考》, 《精通正则表达式》|《设计模式》，《人件》，《代码珠玑》，《算法设计手册》，《程序员修炼之道》，《人月神话》|《计算机程序设计与解释》，《事务处理:概念与技术》，《计算机程序设计模型》，《计算机程序设计艺术》，《数据库系统导论》 C.J Date版，《Thinking Forth》 ，《Little Schemer》（没找到其中译本）||
|博客|听过但是从来抽不出空去接触|阅读一些科技/编程/软件工程的博客，并且经常的收听一些播客|维护一些博客的链接，收集博主分享的有用的文章和工具|维护一个在编程方面，分享有个人见解和思考的博客||

# [Programmer Competency Matrix | Sijin Joseph](https://www.sijinjoseph.com/programmer-competency-matrix/)

> Note that the knowledge for each level is cumulative; being at  
> level _n_ implies that you also know everything from the  
> levels lower than _n_.

|#### Computer Science||||||
|---|---|---|---|---|---|
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|data structures|Doesn’t know the difference between Array and LinkedList|Able to explain and use Arrays, LinkedLists, Dictionaries etc in practical programming tasks|Knows space and time tradeoffs of the basic data structures, Arrays vs LinkedLists, Able to explain how hashtables can be implemented and can handle collisions, Priority queues and ways to implement them etc.|Knowledge of advanced data structures like B-trees, binomial and fibonacci heaps, AVL/Red Black trees, Splay Trees, Skip Lists, tries etc.||
|algorithms|Unable to find the average of numbers in an array (It’s hard to believe but I’ve interviewed such candidates)|Basic sorting, searching and data structure traversal and retrieval algorithms|Tree, Graph, simple greedy and divide and conquer algorithms, is able to understand the relevance of the levels of this matrix.|Able to recognize and code dynamic programming solutions, good knowledge of graph algorithms, good knowledge of numerical computation algorithms, able to identify NP problems etc.||
|systems programming|Doesn’t know what a compiler, linker or interpreter is|Basic understanding of compilers, linker and interpreters. Understands what assembly code is and how things work at the hardware level. Some knowledge of virtual memory and paging.|Understands kernel mode vs. user mode, multi-threading, synchronization primitives and how they’re implemented, able to read assembly code. Understands how networks work, understanding of network protocols and socket level programming.|Understands the entire programming stack, hardware (CPU + Memory + Cache + Interrupts + microcode), binary code, assembly, static and dynamic linking, compilation, interpretation, JIT compilation, garbage collection, heap, stack, memory addressing…||
|#### Software Engineering||||||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|source code version control|Folder backups by date|VSS and beginning CVS/SVN user|Proficient in using CVS and SVN features. Knows how to branch and merge, use patches setup repository properties etc.|Knowledge of distributed VCS systems. Has tried out Bzr/Mercurial/Darcs/Git||
|build automation|Only knows how to build from IDE|Knows how to build the system from the command line|Can setup a script to build the basic system|Can setup a script to build the system and also documentation, installers, generate release notes and tag the code in source control||
|automated testing|Thinks that all testing is the job of the tester|Has written automated unit tests and comes up with good unit test cases for the code that is being written|Has written code in TDD manner|Understands and is able to setup automated functional, load/performance and UI tests||
|#### Programming||||||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|problem decomposition|Only straight line code with copy paste for reuse|Able to break up problem into multiple functions|Able to come up with reusable functions/objects that solve the overall problem|Use of appropriate data structures and algorithms and comes up with generic/object-oriented code that encapsulate aspects of the problem that are subject to change.||
|systems decomposition|Not able to think above the level of a single file/class|Able to break up problem space and design solution as long as it is within the same platform/technology|Able to design systems that span multiple technologies/platforms.|Able to visualize and design complex systems with multiple product lines and integrations with external systems. Also should be able to design operations support systems like monitoring, reporting, fail overs etc.||
|communication|Cannot express thoughts/ideas to peers. Poor spelling and grammar.|Peers can understand what is being said. Good spelling and grammar.|Is able to effectively communicate with peers|Able to understand and communicate thoughts/design/ideas/specs in a unambiguous manner and adjusts communication as per the context|This is an often under rated but very critical criteria for judging a programmer. With the increase in outsourcing of programming tasks to places where English is not the native tongue this issue has become more prominent. I know of several projects that failed because the programmers could not understand what the intent of the communication was.|
|code organization within a file|no evidence of organization within a file|Methods are grouped logically or by accessibility|Code is grouped into regions and well commented with references to other source files|File has license header, summary, well commented, consistent white space usage. The file should look beautiful.||
|code organization across files|No thought given to organizing code across files|Related files are grouped into a folder|Each physical file has a unique purpose, for e.g. one class definition, one feature implementation etc.|Code organization at a physical level closely matches design and looking at file names and folder distribution provides insights into design||
|source tree organization|Everything in one folder|Basic separation of code into logical folders.|No circular dependencies, binaries, libs, docs, builds, third-party code all organized into appropriate folders|Physical layout of source tree matches logical hierarchy and organization. The directory names and organization provide insights into the design of the system.|The difference between this and the previous item is in the scale of organization, source tree organization relates to the entire set of artifacts that define the system.|
|code readability|Mono-syllable names|Good names for files, variables classes, methods etc.|No long functions, comments explaining unusual code, bug fixes, code assumptions|Code assumptions are verified using asserts, code flows naturally – no deep nesting of conditionals or methods||
|defensive coding|Doesn’t understand the concept|Checks all arguments and asserts critical assumptions in code|Makes sure to check return values and check for exceptions around code that can fail.|Has his own library to help with defensive coding, writes unit tests that simulate faults||
|error handling|Only codes the happy case|Basic error handling around code that can throw exceptions/generate errors|Ensures that error/exceptions leave program in good state, resources, connections and memory is all cleaned up properly|Codes to detect possible exception before, maintain consistent exception handling strategy in all layers of code, come up with guidelines on exception handling for entire system.||
|IDE|Mostly uses IDE for text editing|Knows their way around the interface, able to effectively use the IDE using menus.|Knows keyboard shortcuts for most used operations.|Has written custom macros||
|API|Needs to look up the documentation frequently|Has the most frequently used APIs in memory|Vast and In-depth knowledge of the API|Has written libraries that sit on top of the API to simplify frequently used tasks and to fill in gaps in the API|E.g. of API can be Java library, .net framework or the custom API for the application|
|frameworks|Has not used any framework outside of the core platform|Has heard about but not used the popular frameworks available for the platform.|Has used more than one framework in a professional capacity and is well-versed with the idioms of the frameworks.|Author of framework||
|requirements|Takes the given requirements and codes to spec|Come up with questions regarding missed cases in the spec|Understand complete picture and come up with entire areas that need to be speced|Able to suggest better alternatives and flows to given requirements based on experience||
|scripting|No knowledge of scripting tools|Batch files/shell scripts|Perl/Python/Ruby/VBScript/Powershell|Has written and published reusable code||
|database|Thinks that Excel is a database|Knows basic database concepts, normalization, ACID, transactions and can write simple selects|Able to design good and normalized database schemas keeping in mind the queries that’ll have to be run, proficient in use of views, stored procedures, triggers and user defined types. Knows difference between clustered and non-clustered indexes. Proficient in use of ORM tools.|Can do basic database administration, performance optimization, index optimization, write advanced select queries, able to replace cursor usage with relational sql, understands how data is stored internally, understands how indexes are stored internally, understands how databases can be mirrored, replicated etc. Understands how the two phase commit works.||
|#### Experience||||||
||2n (Level 0)|n2 (Level 1)|n (Level 2)|log(n) (Level 3)|Comments|
|languages with professional experience|Imperative or Object Oriented|Imperative, Object-Oriented and declarative (SQL), added bonus if they understand static vs dynamic typing, weak vs strong typing and static inferred types|Functional, added bonus if they understand lazy evaluation, currying, continuations|Concurrent (Erlang, Oz) and Logic (Prolog)||
|platforms with professional experience|1|2-3|4-5|6+||
|years of professional experience|1|2-5|6-9|10+||
|domain knowledge|No knowledge of the domain|Has worked on at least one product in the domain.|Has worked on multiple products in the same domain.|Domain expert. Has designed and implemented several products/solutions in the domain. Well versed with standard terms, protocols used in the domain.||
|#### Knowledge||||||
|tool knowledge|Limited to primary IDE (VS.Net, Eclipse etc.)|Knows about some alternatives to popular and standard tools.|Good knowledge of editors, debuggers, IDEs, open source alternatives etc. etc. For e.g. someone who knows most of the tools from Scott Hanselman’s power tools list. Has used ORM tools.|Has actually written tools and scripts, added bonus if they’ve been published.||
|languages exposed to|Imperative or Object Oriented|Imperative, Object-Oriented and declarative (SQL), added bonus if they understand static vs dynamic typing, weak vs strong typing and static inferred types|Functional, added bonus if they understand lazy evaluation, currying, continuations|Concurrent (Erlang, Oz) and Logic (Prolog)||
|codebase knowledge|Has never looked at the codebase|Basic knowledge of the code layout and how to build the system|Good working knowledge of code base, has implemented several bug fixes and maybe some small features.|Has implemented multiple big features in the codebase and can easily visualize the changes required for most features or bug fixes.||
|knowledge of upcoming technologies|Has not heard of the upcoming technologies|Has heard of upcoming technologies in the field|Has downloaded the alpha preview/CTP/beta and read some articles/manuals|Has played with the previews and has actually built something with it and as a bonus shared that with everyone else||
|platform internals|Zero knowledge of platform internals|Has basic knowledge of how the platform works internally|Deep knowledge of platform internals and can visualize how the platform takes the program and converts it into executable code.|Has written tools to enhance or provide information on platform internals. For e.g. disassemblers, decompilers, debuggers etc.||
|books|Unleashed series, 21 days series, 24 hour series, dummies series…|Code Complete, Don’t Make me Think, Mastering Regular Expressions|Design Patterns, Peopleware, Programming Pearls, Algorithm Design Manual, Pragmatic Programmer, Mythical Man month|Structure and Interpretation of Computer Programs, Concepts Techniques, Models of Computer Programming, Art of Computer Programming, Database systems , by C. J Date, Thinking Forth, Little Schemer||
|blogs|Has heard of them but never got the time.|Reads tech/programming/software engineering blogs and listens to podcasts regularly.|Maintains a link blog with some collection of useful articles and tools that he/she has collected|Maintains a blog in which personal insights and thoughts on programming are shared||

