file = import_module("/src/util/file.star")


def test_file_from_string_simple_template(plan):
    render_templates_mock = kurtosistest.mock(plan, "render_templates")

    file_artifact = file.from_string(plan, "/path", "{{.Name}}")
    expect.eq(
        render_templates_mock.calls(),
        [
            struct(
                args=[],
                kwargs={
                    "config": {"/path": struct(template="{{`{{.Name}}`}}", data={})}
                },
                return_value=file_artifact,
            )
        ],
    )


def test_file_from_string_weird_template(plan):
    render_templates_mock = kurtosistest.mock(plan, "render_templates")

    file_artifact = file.from_string(plan, "/path", "{{{{.Name}} }{{")
    expect.eq(
        render_templates_mock.calls(),
        [
            struct(
                args=[],
                kwargs={
                    "config": {
                        "/path": struct(
                            template="{{`{{{{.Name}} }{{`}}",
                            data={},
                        )
                    }
                },
                return_value=file_artifact,
            )
        ],
    )


def test_file_from_string_brace_before_closing_delimiter(plan):
    render_templates_mock = kurtosistest.mock(plan, "render_templates")

    # The JSON ends in "{}}}": a "{" right before "}}" broke the previous escaping
    file_artifact = file.from_string(plan, "/path", '{"dependencies":{"12345":{}}}')
    expect.eq(
        render_templates_mock.calls(),
        [
            struct(
                args=[],
                kwargs={
                    "config": {
                        "/path": struct(
                            template='{{`{"dependencies":{"12345":{}}}`}}', data={}
                        )
                    }
                },
                return_value=file_artifact,
            )
        ],
    )


def test_file_from_string_backticks(plan):
    render_templates_mock = kurtosistest.mock(plan, "render_templates")

    file_artifact = file.from_string(plan, "/path", "a `{}` b")
    expect.eq(
        render_templates_mock.calls(),
        [
            struct(
                args=[],
                kwargs={
                    "config": {
                        "/path": struct(
                            template='{{`a `}}{{"`"}}{{`{}`}}{{"`"}}{{` b`}}', data={}
                        )
                    }
                },
                return_value=file_artifact,
            )
        ],
    )


def test_file_from_string_optional_args(plan):
    render_templates_mock = kurtosistest.mock(plan, "render_templates")

    file_artifact = file.from_string(
        plan,
        "/path",
        "Hello!",
        artifact_name="My artifact",
        description="My description",
    )
    expect.eq(
        render_templates_mock.calls(),
        [
            struct(
                args=[],
                kwargs={
                    "config": {"/path": struct(template="Hello!", data={})},
                    "description": "My description",
                    "name": "My artifact",
                },
                return_value=file_artifact,
            )
        ],
    )
