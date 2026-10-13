#include <algorithm>
#include <cmath>
#include <complex>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <sstream>
#include <string>
#include <vector>

using namespace std;
using cd = complex<double>;

static vector<int> parseInts(const string& s) {
    string t = s;
    for (char& c : t) if (c == ',' || c == ';') c = ' ';
    stringstream ss(t);
    vector<int> v; int x;
    while (ss >> x) v.push_back(x);
    return v;
}

static vector<double> parseDoubles(const string& s) {
    string t = s;
    for (char& c : t) if (c == ',' || c == ';') c = ' ';
    stringstream ss(t);
    vector<double> v; double x;
    while (ss >> x) v.push_back(x);
    return v;
}

static int digitSum(long long n) {
    n = llabs(n); int s = 0;
    do { s += int(n % 10); n /= 10; } while (n);
    return s;
}

static bool isPrime(long long n) {
    if (n < 2) return false;
    if (n % 2 == 0) return n == 2;
    for (long long d = 3; d * d <= n; d += 2) if (n % d == 0) return false;
    return true;
}

static long long fromBase(string s, int base) {
    long long value = 0;
    for (char ch : s) {
        if (isspace((unsigned char)ch)) continue;
        int d = isdigit((unsigned char)ch) ? ch - '0' : 10 + toupper(ch) - 'A';
        if (d < 0 || d >= base) throw runtime_error("Недопустимая цифра для системы счисления");
        value = value * base + d;
    }
    return value;
}

static string toBase(long long value, int base) {
    if (value == 0) return "0";
    bool neg = value < 0; if (neg) value = -value;
    const string digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    string out;
    while (value) { out.push_back(digits[value % base]); value /= base; }
    if (neg) out.push_back('-');
    reverse(out.begin(), out.end());
    return out;
}

static cd parseComplex(string s) {
    s.erase(remove_if(s.begin(), s.end(), ::isspace), s.end());
    replace(s.begin(), s.end(), 'j', 'i');
    auto posi = s.find('i');
    if (posi == string::npos) return cd(stod(s), 0);
    s.erase(posi, 1);
    if (s.empty() || s == "+") return cd(0, 1);
    if (s == "-") return cd(0, -1);
    size_t split = string::npos;
    for (size_t i = 1; i < s.size(); ++i) if (s[i] == '+' || s[i] == '-') split = i;
    if (split == string::npos) return cd(0, stod(s));
    string re = s.substr(0, split);
    string im = s.substr(split);
    double iv = (im == "+") ? 1.0 : (im == "-") ? -1.0 : stod(im);
    return cd(stod(re), iv);
}

static string cfmt(cd z) {
    ostringstream os; os << fixed << setprecision(3) << z.real();
    if (z.imag() >= 0) os << "+";
    os << fixed << setprecision(3) << z.imag() << "i";
    return os.str();
}


struct MyComplex {
    double re{}, im{};
    MyComplex operator+(const MyComplex& o) const { return {re+o.re, im+o.im}; }
    MyComplex operator-(const MyComplex& o) const { return {re-o.re, im-o.im}; }
    MyComplex operator*(const MyComplex& o) const { return {re*o.re-im*o.im, re*o.im+im*o.re}; }
    MyComplex operator/(const MyComplex& o) const {
        double d=o.re*o.re+o.im*o.im;
        if(d<1e-15) throw runtime_error("Деление на нулевое комплексное число");
        return {(re*o.re+im*o.im)/d,(im*o.re-re*o.im)/d};
    }
};
static MyComplex toMy(cd z){ return {z.real(), z.imag()}; }
static string cfmt(MyComplex z){ return cfmt(cd(z.re,z.im)); }

using Matrix = vector<vector<cd>>;

static Matrix transpose(const Matrix& a) {
    if (a.empty()) return {};
    Matrix r(a[0].size(), vector<cd>(a.size()));
    for (size_t i=0;i<a.size();++i) for (size_t j=0;j<a[i].size();++j) r[j][i]=a[i][j];
    return r;
}

static Matrix add(const Matrix& a, const Matrix& b) {
    Matrix r=a;
    for(size_t i=0;i<a.size();++i) for(size_t j=0;j<a[i].size();++j) r[i][j]+=b[i][j];
    return r;
}

static Matrix mul(const Matrix& a, const Matrix& b) {
    Matrix r(a.size(), vector<cd>(b[0].size(), 0.0));
    for(size_t i=0;i<a.size();++i) for(size_t k=0;k<b.size();++k) for(size_t j=0;j<b[0].size();++j) r[i][j]+=a[i][k]*b[k][j];
    return r;
}

static cd det(Matrix a) {
    const int n=(int)a.size(); cd ans=1.0;
    for(int i=0;i<n;++i){
        int p=i; for(int j=i+1;j<n;++j) if(abs(a[j][i])>abs(a[p][i])) p=j;
        if(abs(a[p][i])<1e-12) return 0.0;
        if(p!=i){swap(a[p],a[i]); ans=-ans;}
        cd pivot=a[i][i]; ans*=pivot;
        for(int j=i+1;j<n;++j){ cd f=a[j][i]/pivot; for(int k=i;k<n;++k) a[j][k]-=f*a[i][k]; }
    }
    return ans;
}

static Matrix parseMatrixLines(int rows, int cols) {
    Matrix m(rows, vector<cd>(cols));
    cout << "Введите матрицу построчно; элементы через пробел, комплексные в виде a+bi:\n";
    string line;
    getline(cin,line);
    for(int i=0;i<rows;++i){
        getline(cin,line); stringstream ss(line); string token;
        for(int j=0;j<cols;++j){ if(!(ss>>token)) throw runtime_error("Недостаточно элементов в строке"); m[i][j]=parseComplex(token); }
    }
    return m;
}

static void printMatrix(const Matrix& m){
    for(auto& row:m){ for(auto z:row) cout<<setw(18)<<cfmt(z); cout<<"\n"; }
}

static void task01(){
    double a,b; cout<<"a b: "; cin>>a>>b; if(a==0||b==0) throw runtime_error("Числа должны быть ненулевыми");
    a=fabs(a); b=fabs(b);
    cout<<"Сумма модулей: "<<a+b<<"\nРазность модулей: "<<a-b<<"\nПроизведение модулей: "<<a*b<<"\nЧастное модулей: "<<a/b<<"\n";
}

static void task02(){
    long long n; cout<<"Секунд с начала суток: "; cin>>n;
    cout<<"Полных часов: "<<n/3600<<"\nОстаток в секундах: "<<n%3600<<"\n";
}

static void task03(){
    double x,y; cout<<"x y: "; cin>>x>>y;
    bool inside = x*x+y*y<=25.0+1e-12 && (y>=0 || x>=0);
    cout<<(inside?"Точка принадлежит области":"Точка НЕ принадлежит области")<<"\n";
}

static void task04(){
    long long n; cout<<"n: "; cin>>n; long long s=0;
    for(long long i=1;i<=n;++i) s += 2*i*i - i + 1;
    cout<<"P = "<<fixed<<setprecision(3)<<(double)s/3.0<<"\n";
}

static void task05(){
    cout<<"Введите последовательность, 0 — конец: ";
    double prev,cur; cin>>prev; if(prev==0){cout<<"Пустая последовательность\n";return;} bool dec=true;
    while(cin>>cur && cur!=0){ if(cur>=prev) dec=false; prev=cur; }
    cout<<(dec?"Последовательность строго убывающая":"Последовательность НЕ является строго убывающей")<<"\n";
}

static void task06(){
    string s; cout<<"Положительное целое число: "; cin>>s;
    char mx=*max_element(s.begin(),s.end()); size_t pos=s.find(mx)+1;
    cout<<"Наибольшая цифра: "<<mx<<", позиция слева: "<<pos<<"\n";
}

static void task07(){
    int n; cout<<"N: "; cin>>n; vector<long long>a(n); for(auto&x:a)cin>>x; int c=0;
    for(int i=0;i+1<n;++i) if(gcd(a[i],a[i+1])==1) ++c;
    cout<<"Пар соседних взаимно простых чисел: "<<c<<"\n";
}

static void task08(){
    string A,B; cout<<"A (основание 5): ";cin>>A; cout<<"B (основание 8): ";cin>>B;
    long long a=fromBase(A,5), b=fromBase(B,8); long long c=3*b*b-2*b+a;
    cout<<"C в десятичной системе: "<<c<<"\nC в троичной системе: "<<toBase(c,3)<<"\n";
}

static void task09(){
    int n; cout<<"Размер чётный: "; cin>>n; if(n<2||n%2) throw runtime_error("Для этой реализации размер должен быть чётным");
    vector<long long>a(n); for(auto&x:a)cin>>x;
    int odd=count_if(a.begin(),a.end(),[](long long x){return x%2!=0;});
    auto it=min_element(a.begin(),a.end()); long long prod=1; bool any=false;
    for(auto p=a.begin();p!=it;++p){prod*=*p;any=true;}
    int h=n/2; long long sq=0; for(int i=0;i<h;++i){long long d=a[i]-a[h+i];sq+=d*d;}
    auto rit=find_if(a.rbegin(),a.rend(),[](long long x){return x%5==0;});
    if(rit!=a.rend()) a.erase(next(rit).base());
    cout<<"Нечётных элементов: "<<odd<<"\nПроизведение до минимума: "<<(any?to_string(prod):string("нет элементов"))<<"\nСумма квадратов разностей половин: "<<sq<<"\nПосле удаления последнего кратного 5: "; for(auto x:a)cout<<x<<' '; cout<<"\n";
}

static void task10(){
    string line; getline(cin,line); cout<<"X: "; getline(cin,line); auto x=parseInts(line); cout<<"Y: "; getline(cin,line); auto y=parseInts(line);
    vector<int> z; for(int v:x)if(digitSum(v)%2)z.push_back(v); for(int v:y)if(digitSum(v)%2)z.push_back(v);
    vector<int> p; for(int v:z)if(isPrime(v))p.push_back(v); sort(p.rbegin(),p.rend());
    cout<<"Z: ";for(int v:z)cout<<v<<' ';cout<<"\nТри наибольших простых: "; for(int i=0;i<min<int>(3,p.size());++i)cout<<p[i]<<' '; cout<<"\n";
}

static void task11(){
    string line; getline(cin,line); cout<<"Массив вещественных чисел: "; getline(cin,line); auto a=parseDoubles(line);
    int bestL=-1,bestR=-1,bestLen=1e9; int n=a.size();
    for(int i=0;i<n-1;){ if(a[i]>a[i+1]){int j=i+1;while(j<n-1&&a[j]>a[j+1])++j;int len=j-i+1;if(len<bestLen){bestLen=len;bestL=i;bestR=j;}i=j;} else ++i; }
    if(bestL<0){cout<<"Убывающих групп длиной >= 2 нет\n";return;}
    cout<<"Группа минимальной длины ("<<bestLen<<"): ";for(int i=bestL;i<=bestR;++i)cout<<a[i]<<' ';cout<<"\n";
}

static void task12(){
    string line; getline(cin,line); cout<<"Массив (нужно минимум 9 отрицательных): "; getline(cin,line); auto a=parseDoubles(line);
    vector<int> neg; for(int i=0;i<(int)a.size();++i)if(a[i]<0)neg.push_back(i); if(neg.size()<9) throw runtime_error("Нужно минимум 9 отрицательных чисел");
    int l=neg[3],r=neg[8]; if(l>r)swap(l,r); sort(a.begin()+l+1,a.begin()+r);
    cout<<"Результат: ";for(double v:a)cout<<v<<' ';cout<<"\n";
}

static void task13(){
    string path; cout<<"Путь к текстовому файлу: "; cin>>path; ifstream f(path); if(!f) throw runtime_error("Файл не открыт");
    vector<string> lines; string s; while(getline(f,s))lines.push_back(s); if(lines.empty()) throw runtime_error("Файл пуст");
    auto it=min_element(lines.begin(),lines.end(),[](const string&a,const string&b){return a.size()<b.size();}); *it="С новым годом!";
    string out="task13_result.txt"; ofstream g(out); for(auto&x:lines)g<<x<<'\n';
    cout<<"Самая короткая строка заменена. Результат: "<<out<<"\n";
}

static void task14(){
    string sa,sb,sc; cout<<"a: ";cin>>sa;cout<<"b: ";cin>>sb;cout<<"c: ";cin>>sc;
    MyComplex a=toMy(parseComplex(sa)), b=toMy(parseComplex(sb)), c=toMy(parseComplex(sc));
    MyComplex q=(a+b+c)/(a-b+c); MyComplex d=q*q;
    cout<<"d = "<<cfmt(d)<<"\n";
}

static void task15(){
    int n,m; cout<<"Размер A (n): ";cin>>n; Matrix A=parseMatrixLines(n,n); cout<<"Размер B (m): ";cin>>m; Matrix B=parseMatrixLines(m,m);
    Matrix S=add(transpose(A),A); Matrix C=mul(S,S); cd delta=det(B); for(auto&row:C)for(auto&z:row)z*=delta;
    cout<<"det(B) = "<<cfmt(delta)<<"\nC = det(B) * (A^T + A)^2:\n"; printMatrix(C);
}

static const int labels[16]={0,10,22,16,11,45,25,25,4,10,7,8,25,10,1,9};
static bool find25(int v,int&found){ if(v>15)return false; if(labels[v]==25){found=v;return true;} return find25(v*2,found)||find25(v*2+1,found); }
static void task16(){ int v=-1; find25(1,v); cout<<"Первая найденная рекурсивным обходом вершина с пометкой 25: "<<v<<"\n"; }

struct Node{int value;Node*next;};
static Node* swapByTopIndex(Node* head,int i,int j){
    if(i==j)return head; if(i>j)swap(i,j); Node *pi=nullptr,*pj=nullptr,*a=head,*b=head;
    for(int k=0;k<i;++k){pi=a;a=a->next;} for(int k=0;k<j;++k){pj=b;b=b->next;}
    if(pi)pi->next=b; else head=b; if(pj==a){a->next=b->next;b->next=a;} else {pj->next=a; swap(a->next,b->next);} return head;
}
static void task17(){
    cout<<"Введите 5 чисел в порядке помещения в стек (например 1 2 3 4 5): ";vector<int>v(5);for(int&x:v)cin>>x;Node*head=nullptr;
    for(int x:v)head=new Node{x,head}; cout<<"Исходный стек сверху вниз: ";for(Node*p=head;p;p=p->next)cout<<p->value<<' ';cout<<"\n";
    // По условию позиции считаются от первого элемента у Nil: 1-й снизу, 5-й сверху.
    // Для цепочки сверху вниз это индексы 4 и 0.
    head=swapByTopIndex(head,0,4); cout<<"После обмена 1-го и 5-го (только связями): ";for(Node*p=head;p;p=p->next)cout<<p->value<<' ';cout<<"\n";
    while(head){Node*n=head->next;delete head;head=n;}
}

int main(){
    setlocale(LC_ALL, "");
    cout<<"КР АиСД — вариант 15\nНомер задачи 1..17: "; int t; if(!(cin>>t))return 0;
    try{
        switch(t){case 1:task01();break;case 2:task02();break;case 3:task03();break;case 4:task04();break;case 5:task05();break;case 6:task06();break;case 7:task07();break;case 8:task08();break;case 9:task09();break;case 10:task10();break;case 11:task11();break;case 12:task12();break;case 13:task13();break;case 14:task14();break;case 15:task15();break;case 16:task16();break;case 17:task17();break;default:cout<<"Нет такой задачи\n";}
    }catch(const exception&e){cerr<<"Ошибка: "<<e.what()<<"\n";return 1;}
}
