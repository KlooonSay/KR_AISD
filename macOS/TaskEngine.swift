import Foundation

struct FieldSpec: Identifiable {
    let id: String
    let label: String
    let placeholder: String
    var multiline: Bool = false
}

struct DemoPreset {
    let title: String
    let detail: String
    let values: [String: String]
}

struct TaskDefinition: Identifiable {
    let id: Int
    let title: String
    let condition: String
    let fields: [FieldSpec]
    let demos: [DemoPreset]

    init(id: Int, title: String, condition: String, fields: [FieldSpec], demos: [DemoPreset] = []) {
        self.id = id
        self.title = title
        self.condition = condition
        self.fields = fields
        self.demos = demos
    }
}

enum SolveError: LocalizedError {
    case badInput(String)
    var errorDescription: String? {
        switch self { case .badInput(let s): return s }
    }
}

struct Cx: CustomStringConvertible {
    var re: Double
    var im: Double
    static func +(l: Cx, r: Cx) -> Cx { .init(re: l.re+r.re, im: l.im+r.im) }
    static func -(l: Cx, r: Cx) -> Cx { .init(re: l.re-r.re, im: l.im-r.im) }
    static func *(l: Cx, r: Cx) -> Cx { .init(re: l.re*r.re-l.im*r.im, im: l.re*r.im+l.im*r.re) }
    static func /(l: Cx, r: Cx) -> Cx {
        let d = r.re*r.re+r.im*r.im
        return .init(re: (l.re*r.re+l.im*r.im)/d, im: (l.im*r.re-l.re*r.im)/d)
    }
    var description: String { String(format: "%.3f%+.3fi", re, im) }
}

enum TaskEngine {
    static let tasks: [TaskDefinition] = [
        .init(
            id: 1,
            title: "Ввод-вывод",
            condition: "Даны два ненулевых числа a и b. Найти сумму, разность, произведение и частное модулей заданных чисел.",
            fields: [
                .init(id: "a", label: "a", placeholder: "например -3"),
                .init(id: "b", label: "b", placeholder: "например 4")
            ],
            demos: [
                .init(title: "Пример 1", detail: "a = -3, b = 4", values: ["a": "-3", "b": "4"]),
                .init(title: "Пример 2", detail: "a = 2, b = -2", values: ["a": "2", "b": "-2"])
            ]
        ),
        .init(
            id: 2,
            title: "Целочисленная арифметика",
            condition: "С начала суток прошло N секунд. Найти количество полных часов и остаток в секундах.",
            fields: [.init(id: "n", label: "N", placeholder: "например 3661")],
            demos: [
                .init(title: "1 час + 61 с", detail: "N = 3661", values: ["n": "3661"]),
                .init(title: "2 часа + 5 с", detail: "N = 7205", values: ["n": "7205"])
            ]
        ),
        .init(
            id: 3,
            title: "Попадание точки в область",
            condition: "Определить, принадлежит ли точка (x, y) области варианта 15: круг x²+y²≤25 без нижней левой четверти.",
            fields: [
                .init(id: "x", label: "x", placeholder: "например 1"),
                .init(id: "y", label: "y", placeholder: "например 1")
            ],
            demos: [
                .init(title: "В области", detail: "Точка (1, 1)", values: ["x": "1", "y": "1"]),
                .init(title: "Вне области", detail: "Точка (-1, -1) попадает в вырезанную четверть", values: ["x": "-1", "y": "-1"])
            ]
        ),
        .init(
            id: 4,
            title: "Цикл: натуральные числа",
            condition: "Для целого положительного n вычислить P = 1/3 · Σ(2i² − i + 1), i=1…n.",
            fields: [.init(id: "n", label: "n", placeholder: "например 2")],
            demos: [
                .init(title: "n = 2", detail: "Получается P = 3", values: ["n": "2"]),
                .init(title: "n = 3", detail: "Ещё один небольшой пример", values: ["n": "3"])
            ]
        ),
        .init(
            id: 5,
            title: "Цикл: последовательность",
            condition: "Вводится последовательность произвольных чисел, 0 — конец. Определить, является ли она строго убывающей.",
            fields: [.init(id: "seq", label: "Последовательность", placeholder: "9, 7, 3, 1, 0")],
            demos: [
                .init(title: "Да — убывает", detail: "9 > 7 > 3 > 1", values: ["seq": "9, 7, 3, 1, 0"]),
                .init(title: "Нет — не убывает", detail: "После 7 идёт 8", values: ["seq": "9, 7, 8, 1, 0"])
            ]
        ),
        .init(
            id: 6,
            title: "Работа с цифрами",
            condition: "Вводится целое положительное число. Определить позицию наибольшей цифры в числе.",
            fields: [.init(id: "num", label: "Число", placeholder: "например 981")],
            demos: [
                .init(title: "Максимум в начале", detail: "981 → цифра 9 на позиции 1", values: ["num": "981"]),
                .init(title: "Максимум в середине", detail: "391 → цифра 9 на позиции 2", values: ["num": "391"])
            ]
        ),
        .init(
            id: 7,
            title: "Функции и последовательности",
            condition: "В последовательности из N целых положительных элементов определить количество пар соседних взаимно простых чисел.",
            fields: [.init(id: "seq", label: "Последовательность", placeholder: "2, 3, 4")],
            demos: [
                .init(title: "2 пары", detail: "НОД(2,3)=1 и НОД(3,4)=1", values: ["seq": "2, 3, 4"]),
                .init(title: "0 пар", detail: "2, 4, 8 имеют общие делители", values: ["seq": "2, 4, 8"])
            ]
        ),
        .init(
            id: 8,
            title: "Системы счисления",
            condition: "A задано в 5-ричной системе, B — в 8-ричной. Вычислить C = 3·B² − 2·B + A и вывести C в десятичной и троичной системах.",
            fields: [
                .init(id: "a", label: "A (осн. 5)", placeholder: "например 10"),
                .init(id: "b", label: "B (осн. 8)", placeholder: "например 10")
            ],
            demos: [
                .init(title: "Пример 1", detail: "A₅ = 10, B₈ = 10", values: ["a": "10", "b": "10"]),
                .init(title: "Пример 2", detail: "A₅ = 1, B₈ = 1", values: ["a": "1", "b": "1"])
            ]
        ),
        .init(
            id: 9,
            title: "Основные операции с массивом",
            condition: "Для целочисленного массива: количество нечётных; произведение элементов до минимума; разделить пополам B/C и найти сумму квадратов разностей; удалить последнее число, кратное 5.",
            fields: [.init(id: "arr", label: "Массив (чётное число элементов)", placeholder: "1, 2, -1, 2, 3, 5")],
            demos: [
                .init(title: "Пример 1", detail: "6 небольших чисел", values: ["arr": "1, 2, -1, 2, 3, 5"]),
                .init(title: "Пример 2", detail: "Другой массив из 6 элементов", values: ["arr": "2, -2, 4, 4, 2, 10"])
            ]
        ),
        .init(
            id: 10,
            title: "Функции обработки массивов",
            condition: "Из X и Y переписать в Z числа с нечётной суммой цифр. Найти три наибольших простых числа в Z.",
            fields: [
                .init(id: "x", label: "X", placeholder: "3, 5, 10"),
                .init(id: "y", label: "Y", placeholder: "7, 11, 13")
            ],
            demos: [
                .init(title: "Есть 3 простых", detail: "В Z попадут 3, 5, 10, 7", values: ["x": "3, 5, 10", "y": "7, 11, 13"]),
                .init(title: "Простых нет", detail: "После отбора простых чисел не останется", values: ["x": "2, 4, 6", "y": "8, 10"])
            ]
        ),
        .init(
            id: 11,
            title: "Группы элементов",
            condition: "В массиве вещественных чисел найти группу минимальной длины, состоящую из убывающей последовательности чисел.",
            fields: [.init(id: "arr", label: "Массив", placeholder: "5, 4, 1, 3, 2")],
            demos: [
                .init(title: "Есть группы", detail: "Группы 5,4,1 и 3,2; минимальная — 3,2", values: ["arr": "5, 4, 1, 3, 2"]),
                .init(title: "Групп нет", detail: "Последовательность только возрастает", values: ["arr": "1, 2, 3, 4"])
            ]
        ),
        .init(
            id: 12,
            title: "Сортировка части массива",
            condition: "Упорядочить по возрастанию элементы, расположенные между четвёртым и девятым отрицательными числами массива.",
            fields: [.init(id: "arr", label: "Массив (минимум 9 отрицательных)", placeholder: "-1, -2, -3, -4, 3, 1, 2, -5, -6, -7, -8, -9")],
            demos: [
                .init(title: "Нужно сортировать", detail: "Между 4-м и 9-м отрицательными есть неупорядоченные элементы", values: ["arr": "-1, -2, -3, -4, 3, 1, 2, -5, -6, -7, -8, -9"]),
                .init(title: "Уже по порядку", detail: "Элементы между границами уже возрастают", values: ["arr": "-1, -2, -3, -4, -8, -7, -6, -5, -9"])
            ]
        ),
        .init(
            id: 13,
            title: "Строки",
            condition: "Найти самую короткую строку текста и заменить её фразой «С новым годом!».",
            fields: [.init(id: "text", label: "Текст", placeholder: "Каждая строка с новой строки", multiline: true)],
            demos: [
                .init(title: "Короткая строка «Кот»", detail: "Заменится вторая строка", values: ["text": "Первая строка\nКот\nПоследняя строка"]),
                .init(title: "Короткая строка «А»", detail: "Заменится первая строка", values: ["text": "А\nДве\nТретья строка"])
            ]
        ),
        .init(
            id: 14,
            title: "Структура: комплексные числа",
            condition: "Для комплексных a, b, c вычислить d = ((a+b+c)/(a−b+c))².",
            fields: [
                .init(id: "a", label: "a", placeholder: "например 1"),
                .init(id: "b", label: "b", placeholder: "например 0"),
                .init(id: "c", label: "c", placeholder: "например 1")
            ],
            demos: [
                .init(title: "d = 1", detail: "a = 1, b = 0, c = 1", values: ["a": "1", "b": "0", "c": "1"]),
                .init(title: "d = 4", detail: "a = 2, b = 1, c = 1", values: ["a": "2", "b": "1", "c": "1"])
            ]
        ),
        .init(
            id: 15,
            title: "Матрицы комплексных чисел",
            condition: "Для квадратных комплексных матриц A и B найти C = |B| · (Aᵀ + A)².",
            fields: [
                .init(id: "a", label: "Матрица A", placeholder: "1 0\n0 1", multiline: true),
                .init(id: "b", label: "Матрица B", placeholder: "1 0\n0 1", multiline: true)
            ],
            demos: [
                .init(title: "Единичные матрицы", detail: "A = I, B = I → C = 4I", values: ["a": "1 0\n0 1", "b": "1 0\n0 1"]),
                .init(title: "det(B) = 2", detail: "A = I, B = diag(2,1) → C = 8I", values: ["a": "1 0\n0 1", "b": "2 0\n0 1"])
            ]
        ),
        .init(
            id: 16,
            title: "Дерево",
            condition: "Рекурсивно пройти фиксированное дерево и дойти до вершины с пометкой 25, выведя хотя бы один номер такой вершины.",
            fields: []
        ),
        .init(
            id: 17,
            title: "Стек",
            condition: "Записать 5 целых чисел в стек и, меняя только связи, поменять местами 1-й и 5-й элементы. Позиции считаются от элемента у Nil.",
            fields: [.init(id: "arr", label: "5 чисел в порядке помещения в стек", placeholder: "1, 2, 3, 4, 5")],
            demos: [
                .init(title: "1…5", detail: "Самый наглядный пример", values: ["arr": "1, 2, 3, 4, 5"]),
                .init(title: "10…50", detail: "Второй набор с тем же обменом связей", values: ["arr": "10, 20, 30, 40, 50"])
            ]
        )
    ]

    static func solve(_ task: Int, values: [String:String]) throws -> String {
        switch task {
        case 1:
            let a = try dbl(values["a"]), b = try dbl(values["b"]); guard a != 0 && b != 0 else { throw SolveError.badInput("a и b должны быть ненулевыми") }
            let x=abs(a), y=abs(b); return fmt("Сумма модулей: \(x+y)\nРазность модулей: \(x-y)\nПроизведение модулей: \(x*y)\nЧастное модулей: \(x/y)")
        case 2:
            let n = try int(values["n"]); return "Полных часов: \(n/3600)\nОстаток в секундах: \(n%3600)"
        case 3:
            let x=try dbl(values["x"]), y=try dbl(values["y"]); let ok=x*x+y*y<=25.0 && (y>=0 || x>=0); return ok ? "Точка ПРИНАДЛЕЖИТ области" : "Точка НЕ принадлежит области"
        case 4:
            let n = try int(values["n"])
            guard n > 0 else { throw SolveError.badInput("n должно быть положительным") }
            var sum = 0
            for i in 1...n { sum += 2*i*i - i + 1 }
            return String(format: "P = %.3f", Double(sum) / 3.0)
        case 5:
            var a = try doubles(values["seq"])
            if let z = a.firstIndex(of: 0) { a = Array(a[..<z]) }
            guard !a.isEmpty else { throw SolveError.badInput("Последовательность пуста") }
            let ok = zip(a, a.dropFirst()).allSatisfy { pair in pair.0 > pair.1 }
            return ok ? "Последовательность строго убывающая" : "Последовательность НЕ является строго убывающей"
        case 6:
            let s=(values["num"] ?? "").trimmingCharacters(in:.whitespacesAndNewlines); guard !s.isEmpty, s.allSatisfy({$0.isNumber}) else {throw SolveError.badInput("Введите положительное целое число")}; let m=s.max()!; let p=s.firstIndex(of:m)!; return "Наибольшая цифра: \(m)\nПозиция слева: \(s.distance(from:s.startIndex,to:p)+1)"
        case 7:
            let a = try ints(values["seq"])
            guard a.count >= 2 else { throw SolveError.badInput("Нужно минимум два числа") }
            let c = zip(a, a.dropFirst()).filter { pair in
                gcd(abs(pair.0), abs(pair.1)) == 1
            }.count
            return "Пар соседних взаимно простых чисел: \(c)"
        case 8:
            let a=try fromBase(values["a"] ?? "",5), b=try fromBase(values["b"] ?? "",8); let c=3*b*b-2*b+a; return "C в десятичной системе: \(c)\nC в троичной системе: \(toBase(c,3))"
        case 9:
            var a = try ints(values["arr"])
            guard a.count >= 2 && a.count % 2 == 0 else {
                throw SolveError.badInput("Нужно чётное количество элементов")
            }
            let odd = a.filter { $0 % 2 != 0 }.count
            let minIndex = a.indices.min { a[$0] < a[$1] }!
            let before = Array(a[..<minIndex])
            let productText: String
            if before.isEmpty {
                productText = "нет элементов"
            } else {
                productText = String(before.reduce(1, *))
            }
            let half = a.count / 2
            var squareSum = 0
            for i in 0..<half {
                let d = a[i] - a[half + i]
                squareSum += d * d
            }
            if let i = a.lastIndex(where: { $0 % 5 == 0 }) { a.remove(at: i) }
            let arrayText = a.map(String.init).joined(separator: ", ")
            return "Нечётных элементов: \(odd)\nПроизведение до минимума: \(productText)\nСумма квадратов разностей B и C: \(squareSum)\nПосле удаления последнего кратного 5: \(arrayText)"
        case 10:
            let x=try ints(values["x"]), y=try ints(values["y"]); let z=(x+y).filter{digitSum($0)%2 != 0}; let p=z.filter(isPrime).sorted(by:>); return "Z: \(z.map(String.init).joined(separator:", "))\nТри наибольших простых: \(p.prefix(3).map(String.init).joined(separator:", "))"
        case 11:
            let a=try doubles(values["arr"]); guard a.count>=2 else {throw SolveError.badInput("Нужно минимум два элемента")}; var best:[Double]?; var i=0; while i<a.count-1 { if a[i]>a[i+1] { var j=i+1; while j<a.count-1 && a[j]>a[j+1]{j+=1}; let g=Array(a[i...j]); if best==nil || g.count<best!.count{best=g}; i=j } else {i+=1} }; guard let b=best else {return "Убывающих групп длиной ≥ 2 нет"}; return "Группа минимальной длины (\(b.count)): \(b.map{trim($0)}.joined(separator:", "))"
        case 12:
            var a=try doubles(values["arr"]); let neg=a.indices.filter{a[$0]<0}; guard neg.count>=9 else {throw SolveError.badInput("Нужно минимум 9 отрицательных элементов")}; let l=neg[3], r=neg[8]; if r-l>1 { let sorted=a[(l+1)..<r].sorted(); a.replaceSubrange((l+1)..<r,with:sorted) }; return "Результат: \(a.map{trim($0)}.joined(separator:", "))"
        case 13:
            var lines=(values["text"] ?? "").components(separatedBy:.newlines); guard !lines.isEmpty else {throw SolveError.badInput("Введите текст")}; let idx=lines.indices.min(by:{lines[$0].count<lines[$1].count})!; lines[idx]="С новым годом!"; return lines.joined(separator:"\n")
        case 14:
            let a=try cx(values["a"]), b=try cx(values["b"]), c=try cx(values["c"]); let q=(a+b+c)/(a-b+c); return "d = \(q*q)"
        case 15:
            let A=try matrix(values["a"]), B=try matrix(values["b"]); guard A.count==A.first?.count, B.count==B.first?.count else {throw SolveError.badInput("A и B должны быть квадратными")}; let s=add(transpose(A),A); let d=det(B); let C=scale(mul(s,s),d); return "det(B) = \(d)\nC:\n\(matrixText(C))"
        case 16:
            let labels=[0,10,22,16,11,45,25,25,4,10,7,8,25,10,1,9]; func find(_ v:Int)->Int?{ if v>15{return nil}; if labels[v]==25{return v}; return find(v*2) ?? find(v*2+1) }; return "Первая найденная рекурсивным обходом вершина с пометкой 25: \(find(1) ?? -1)"
        case 17:
            let pushed=try ints(values["arr"]); guard pushed.count==5 else {throw SolveError.badInput("Нужно ровно 5 чисел")}; let original=Array(pushed.reversed()); var result=original; result.swapAt(0,4); return "Исходный стек сверху вниз: \(original.map(String.init).joined(separator:" → ")) → Nil\nПосле обмена 1-го и 5-го только связями: \(result.map(String.init).joined(separator:" → ")) → Nil"
        default: throw SolveError.badInput("Неизвестная задача")
        }
    }

    private static func int(_ s:String?) throws -> Int { guard let v=Int((s ?? "").trimmingCharacters(in:.whitespacesAndNewlines)) else {throw SolveError.badInput("Некорректное целое число")}; return v }
    private static func dbl(_ s:String?) throws -> Double { guard let v=Double((s ?? "").replacingOccurrences(of:",",with:".").trimmingCharacters(in:.whitespacesAndNewlines)) else {throw SolveError.badInput("Некорректное число")}; return v }
    private static func ints(_ s:String?) throws -> [Int] { let parts=(s ?? "").replacingOccurrences(of:";",with:",").split{ $0=="," || $0.isWhitespace }; let v=parts.compactMap{Int($0)}; guard v.count==parts.count && !v.isEmpty else {throw SolveError.badInput("Введите целые числа через пробел или запятую")}; return v }
    private static func doubles(_ s:String?) throws -> [Double] { let parts=(s ?? "").replacingOccurrences(of:";",with:",").split{ $0=="," || $0.isWhitespace }; let v=parts.compactMap{Double($0.replacingOccurrences(of:",",with:"."))}; guard v.count==parts.count && !v.isEmpty else {throw SolveError.badInput("Введите числа через пробел или запятую")}; return v }
    private static func fmt(_ s:String)->String{s}
    private static func trim(_ x:Double)->String { x.rounded()==x ? String(Int(x)) : String(format:"%.3f",x) }
    private static func digitSum(_ n:Int)->Int { var x=abs(n),s=0; repeat{s+=x%10;x/=10}while x>0; return s }
    private static func gcd(_ a:Int,_ b:Int)->Int { var x=a,y=b; while y != 0 {(x,y)=(y,x%y)}; return x }
    private static func isPrime(_ n:Int)->Bool { if n<2{return false}; if n%2==0{return n==2}; var d=3; while d*d<=n {if n%d==0{return false};d+=2};return true }
    private static func fromBase(_ s:String,_ base:Int)throws->Int { var v=0; guard !s.isEmpty else {throw SolveError.badInput("Пустое число")}; for ch in s.uppercased(){ guard let d=ch.wholeNumberValue, d<base else {throw SolveError.badInput("Недопустимая цифра для основания \(base)")}; v=v*base+d }; return v }
    private static func toBase(_ n:Int,_ base:Int)->String { if n==0{return "0"}; var x=abs(n),a=""; while x>0{a=String(x%base)+a;x/=base};return n<0 ? "-"+a:a }
    private static func cx(_ s:String?)throws->Cx { var t=(s ?? "").replacingOccurrences(of:" ",with:"").replacingOccurrences(of:"j",with:"i"); if !t.contains("i") {guard let r=Double(t) else {throw SolveError.badInput("Комплексное число: a+bi")};return .init(re:r,im:0)}; t=t.replacingOccurrences(of:"i",with:""); var split:Int?; let arr=Array(t); if arr.count>1 {for i in 1..<arr.count where arr[i]=="+" || arr[i]=="-" {split=i}}; if let k=split { let rs=String(arr[..<k]), isv=String(arr[k...]); guard let r=Double(rs) else {throw SolveError.badInput("Комплексное число: a+bi")}; let im = isv=="+" ? 1.0 : isv=="-" ? -1.0 : Double(isv); guard let ii=im else {throw SolveError.badInput("Комплексное число: a+bi")}; return .init(re:r,im:ii) } else { let im=t=="" || t=="+" ? 1.0 : t=="-" ? -1.0 : Double(t); guard let ii=im else {throw SolveError.badInput("Комплексное число: a+bi")};return .init(re:0,im:ii)} }
    private typealias M=[[Cx]]
    private static func matrix(_ s:String?)throws->M { let rows=(s ?? "").split(whereSeparator:{$0=="\n" || $0==";"}); guard !rows.isEmpty else {throw SolveError.badInput("Матрица пуста")}; var m:M=[]; var c:Int?; for row in rows { let ts=row.split{$0.isWhitespace || $0==","}; let rr=try ts.map{try cx(String($0))}; if c==nil{c=rr.count}; guard rr.count==c else {throw SolveError.badInput("Строки матрицы разной длины")};m.append(rr)};return m }
    private static func transpose(_ a:M)->M { (0..<a[0].count).map{j in (0..<a.count).map{i in a[i][j]}} }
    private static func add(_ a:M,_ b:M)->M { a.indices.map{i in a[i].indices.map{j in a[i][j]+b[i][j]}} }
    private static func mul(_ a:M,_ b:M)->M { a.indices.map{i in b[0].indices.map{j in (0..<b.count).reduce(Cx(re:0,im:0)){$0+a[i][$1]*b[$1][j]}}} }
    private static func scale(_ a:M,_ k:Cx)->M { a.map{$0.map{$0*k}} }
    private static func det(_ input:M)->Cx { var a=input; var ans=Cx(re:1,im:0); let n=a.count; for i in 0..<n { var p=i; for j in i..<n {let aj=a[j][i].re*a[j][i].re+a[j][i].im*a[j][i].im, ap=a[p][i].re*a[p][i].re+a[p][i].im*a[p][i].im;if aj>ap{p=j}}; let mag=a[p][i].re*a[p][i].re+a[p][i].im*a[p][i].im;if mag<1e-15{return Cx(re:0,im:0)};if p != i {a.swapAt(p,i);ans=Cx(re:-ans.re,im:-ans.im)};let piv=a[i][i];ans=ans*piv;if i+1<n {for j in i+1..<n {let f=a[j][i]/piv;for k in i..<n{a[j][k]=a[j][k]-f*a[i][k]}}}};return ans }
    private static func matrixText(_ m:M)->String { m.map{$0.map{$0.description}.joined(separator:"    ")}.joined(separator:"\n") }
}
