# Eway: Your Fast Lane to Flutter App Creation 🚀

[![pub package](https://img.shields.io/pub/v/eway.svg)](https://pub.dev/packages/eway)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![stars](https://img.shields.io/github/stars/yourusername/eway.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/yourusername/eway)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Eway is a powerful CLI tool that supercharges your Flutter development process. Create fully-configured Flutter apps in seconds, not hours!

## 🌟 Features

- 🎨 **Template-based Creation**: Choose from a variety of pre-configured templates
- 🔧 **Customizable Setup**: Tailor your app's configuration through an interactive CLI
- 🚀 **Rapid Development**: Get your project up and running in no time
- 🛠 **Automated Configuration**: Say goodbye to manual setup of package names and dependencies
- 📦 **Pre-installed Packages**: Start with the most popular Flutter packages ready to go

## 🚀 Quick Start

1. Install Eway:
   ```
   dart pub global activate eway
   ```

2. Create your Flutter app:
   ```
   eway create my_awesome_app
   ```

3. Follow the interactive prompts to customize your app

4. cd into your new project:
   ```
   cd my_awesome_app
   ```

5. Run your app:
   ```
   flutter run
   ```
## 🎨 Template Customization

Eway offers a wide range of customization options. Here's a breakdown of the available features:

| Feature | Options | Status |
|---------|---------|--------|
| Backend | 🔥 Firebase<br>🌐 REST API | 🟢<br>🔴 |
| State Management | 🔄 Riverpod<br>🧱 BLoC<br>⚡ GetX | 🟢<br>🔴<br>🔴 |
| Localization | 🌍 Multi-language (l10n)<br>🏠 Single language | 🟢<br>🟢 |
| Themes | 🌑 Dark Theme<br>🌕 Light Theme<br>💡 Both | 🟢<br>🟢<br>🟢 |
| Environment | 🏗️ Single Environment<br>🏙️ Multiple Environments | 🟢<br>🔴 |
| Firebase Notifications | 🔔 Enabled<br>🔕 Disabled | 🟢<br>🟢 |
| Routing | 📍 App Router<br>📍 Go Router | 🔴<br>🟢 |

🟢 Available   🔴 Coming Soon

Currently, all Riverpod-based features are fully implemented. We're actively working on expanding the available options for each feature.
## 🛠 Customization Options

During the creation process, you can customize:

- 📱 App Name and Package Name
- 🔥 Backend (Firebase / REST API)
- 🌐 Localization
- 🎨 Themes (Light / Dark / Both)
- 🌍 Environment Setup
- 🔔 Firebase Notifications
- 🧠 State Management (Riverpod / BLoC / GetX)
- 🧭 Routing (App Router / Go Router)

## 📋 TODO

We're constantly working to improve Eway. Here's what's on our roadmap:

- [ ] Add more state management options (MobX, Provider)
- [ ] Implement GraphQL template
- [ ] Create template for Flutter web projects
- [ ] Add option for Flutter desktop apps
- [ ] Implement CI/CD templates
- [ ] Create more specialized templates (e.g., e-commerce, social media)

## 🤝 Contributing

We welcome contributions! Check out our [Contributing Guide](CONTRIBUTING.md) for more information on how to get started.

## 📄 License

Eway is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## 💖 Support

If you find Eway helpful, please consider giving it a star ⭐ on GitHub and sharing it with your fellow Flutter developers!

---

Built with 💙 by hberkayozdemir/eway and the Flutter community.
