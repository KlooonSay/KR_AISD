import SwiftUI

struct ContentView: View {
    @State private var selected: Int? = 1
    @State private var values: [String: String] = [:]
    @State private var result = ""
    @State private var errorMessage = ""

    private var task: TaskDefinition {
        TaskEngine.tasks[(selected ?? 1) - 1]
    }

    var body: some View {
        NavigationSplitView {
            List(TaskEngine.tasks, selection: $selected) { task in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(task.id)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .frame(width: 24, height: 24)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

                    Text(task.title)
                        .font(.callout)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
                .tag(task.id)
            }
            .navigationTitle("Задачи")
            .navigationSplitViewColumnWidth(min: 190, ideal: 225, max: 275)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    conditionBox

                    if !task.fields.isEmpty {
                        demoControls
                        inputFields
                    }

                    actionButton
                    messageArea
                    resultBox
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Контрольная работа — АиСД")
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            loadFirstDemo()
        }
        .onChange(of: selected) { _ in
            loadFirstDemo()
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                titleBlock
                Spacer(minLength: 20)
                variantBadge
            }

            VStack(alignment: .leading, spacing: 10) {
                titleBlock
                variantBadge
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Задача \(task.id)")
                .font(.title2.bold())
            Text(task.title)
                .foregroundStyle(.secondary)
        }
    }

    private var variantBadge: some View {
        Text("Вариант 15")
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }

    private var conditionBox: some View {
        GroupBox("Условие") {
            Text(task.condition)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var demoControls: some View {
        GroupBox("Проверочные данные") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Первый пример уже подставлен. Можно выбрать второй набор или очистить поля и ввести свои значения.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        demoButtons
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        demoButtons
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var demoButtons: some View {
        ForEach(Array(task.demos.enumerated()), id: \.offset) { _, demo in
            Button {
                apply(demo)
            } label: {
                Label(demo.title, systemImage: "testtube.2")
            }
            .help(demo.detail)
        }

        Button("Очистить") {
            values = [:]
            result = ""
            errorMessage = ""
        }
    }

    private var inputFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(task.fields) { field in
                VStack(alignment: .leading, spacing: 6) {
                    Text(field.label)
                        .font(.subheadline.weight(.medium))

                    if field.multiline {
                        TextEditor(text: binding(field.id))
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 110)
                            .padding(6)
                            .background(.background, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                    } else {
                        TextField(field.placeholder, text: binding(field.id))
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButton: some View {
        Button {
            runTask()
        } label: {
            Label(task.id == 16 ? "Найти" : "Выполнить", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    @ViewBuilder
    private var messageArea: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var resultBox: some View {
        GroupBox("Результат") {
            ScrollView([.vertical, .horizontal]) {
                Text(result.isEmpty ? "Здесь появится результат вычисления." : result)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(result.isEmpty ? .secondary : .primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 6)
            }
            .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    private func binding(_ key: String) -> Binding<String> {
        Binding(
            get: { values[key, default: ""] },
            set: { values[key] = $0 }
        )
    }

    private func apply(_ demo: DemoPreset) {
        values = demo.values
        result = ""
        errorMessage = ""
    }

    private func loadFirstDemo() {
        result = ""
        errorMessage = ""
        values = task.demos.first?.values ?? [:]
    }

    private func runTask() {
        do {
            result = try TaskEngine.solve(task.id, values: values)
            errorMessage = ""
        } catch let err {
            errorMessage = err.localizedDescription
            result = ""
        }
    }
}
