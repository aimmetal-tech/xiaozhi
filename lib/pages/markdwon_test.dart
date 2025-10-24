import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownPage extends StatefulWidget {
  const MarkdownPage({super.key});

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  @override
  Widget build(BuildContext context) {
    final String data = '''
# H1
## H2
### H3
Regular

**Bold**

```python
pip install langchain
```
''';
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: MarkdownWidget(data: data),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {},
        child: Icon(Icons.sync),
      ),
    );
  }
}
