import 'package:finlytics/app/categories/subcategory_form.dart';
import 'package:finlytics/core/database/app_db.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/supported-icon/supported_icon.dart';
import 'package:finlytics/core/presentation/widgets/icon_selector_modal.dart';
import 'package:finlytics/core/presentation/widgets/persistent_footer_button.dart';
import 'package:finlytics/core/services/supported_icon/supported_icon_service.dart';
import 'package:finlytics/core/utils/color_utils.dart';
import 'package:finlytics/core/utils/text_field_validator.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key, this.categoryUUID});

  /// Account UUID to edit (if any)
  final String? categoryUUID;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  Category? categoryToEdit;

  final TextEditingController _nameController = TextEditingController();

  SupportedIcon _icon = SupportedIconService.instance.defaultSupportedIcon;

  String _color = '000000';
  CategoryType _type = CategoryType.E;

  final colorOptions = [
    'B71C1C',
    'D50000',
    'E53935',
    'EF5350',
    '880E4F',
    'C51162',
    'D81B60',
    'EC407A',
    '4A148C',
    'AA00FF',
    '8E24AA',
    'AB47BC',
    '1A237E',
    '2962FF',
    '2979FF',
    '42A5F5',
    '006064',
    '00897B',
    '00BFA5',
    '4DB6AC',
    '1B5E20',
    '388E3C',
    '8BC34A',
    'D4E157',
    'BF360C',
    'F4511E',
    'FB8C00',
    'FFA726',
    'E65100',
    'FFA000',
    'FFAB00',
    'FFCA28',
    '546E7A',
    '90A4AE',
    '795548',
    '757575',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.categoryUUID != null) {
      _fillForm();
    }
  }

  void _fillForm() {
    CategoryService.instance
        .getCategoryById(widget.categoryUUID!)
        .first
        .then((category) async {
      categoryToEdit = category;

      setState(() {
        _icon = categoryToEdit!.icon;
        _color = categoryToEdit!.color;
        _type = categoryToEdit!.type;
      });

      _nameController.value = TextEditingValue(text: categoryToEdit!.name);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  deleteCategory(String categoryId) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.general.delete),
          content: const SingleChildScrollView(
              child: Text(
                  'This action will irreversibly delete all transactions <b>({{x}})</b> related to this category.')),
          actions: [
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                CategoryService.instance
                    .deleteCategory(categoryId)
                    .then((value) async {
                  if (categoryId == widget.categoryUUID) {
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.categories.delete_success)));
                  }
                }).catchError((error) {});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  makeMainCategory(Category category) {
    if (category.isMainCategory) return;

    CategoryService.instance.updateCategory(CategoryInDB(
        id: category.id,
        name: category.name,
        iconId: category.icon.id,
        color: categoryToEdit!.color,
        type: categoryToEdit!.type));

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría creada con exito')));
  }

  openSubcategoryForm(
      {required void Function(String, SupportedIcon) onSubmit,
      Category? subcategory}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SubcategoryFormDialog(
            name: subcategory?.name ?? '',
            color: ColorHex.get(_color),
            icon: subcategory?.icon ??
                SupportedIconService.instance.defaultSupportedIcon,
            onSubmit: onSubmit,
          );
        });
  }

  submitForm() {
    final messager = ScaffoldMessenger.of(context);

    if (categoryToEdit != null) {
      categoryToEdit = Category(
          id: categoryToEdit!.id,
          name: _nameController.text,
          iconId: _icon.id,
          color: _color,
          parentCategory: categoryToEdit!.parentCategory,
          type: categoryToEdit!.type);

      CategoryService.instance.updateCategory(categoryToEdit!).then((value) {
        messager
            .showSnackBar(SnackBar(content: Text(t.categories.edit_success)));
      }).catchError((error) {
        messager.showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else {
      CategoryService.instance
          .insertCategory(CategoryInDB(
              id: const Uuid().v4(),
              name: _nameController.text,
              iconId: _icon.id,
              type: _type,
              color: _color))
          .then((value) {
        messager
            .showSnackBar(SnackBar(content: Text(t.categories.create_success)));
      }).catchError((error) {
        messager.showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
        persistentFooterButtons: [
          PersistentFooterButton(
            child: FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  submitForm();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Guardar cambios'),
            ),
          )
        ],
        appBar: AppBar(
            title: Text(widget.categoryUUID != null
                ? t.categories.edit
                : t.categories.create),
            actions: [
              if (widget.categoryUUID != null)
                PopupMenuButton(
                  itemBuilder: (context) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem(
                          value: 'to_subcategory',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.login),
                            minLeadingWidth: 26,
                            title: Text(t.categories.make_child),
                          )),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'merge',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.merge_type),
                            minLeadingWidth: 26,
                            title: Text(t.categories.merge),
                          )),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.delete),
                            minLeadingWidth: 26,
                            title: Text(t.general.delete),
                          ))
                    ];
                  },
                  onSelected: (String value) {
                    if (value == 'delete') deleteCategory(widget.categoryUUID!);
                  },
                ),
            ]),
        body: widget.categoryUUID != null && categoryToEdit == null
            ? const LinearProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            showDragHandle: true,
                                            builder: (context) {
                                              return IconSelectorModal(
                                                preselectedIconID: _icon.id,
                                                onIconSelected: (selectedIcon) {
                                                  setState(() {
                                                    _icon = selectedIcon;
                                                  });
                                                },
                                              );
                                            });
                                      },
                                      child: Builder(builder: (context) {
                                        final iconColor = ColorHex.get(_color);

                                        return Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color:
                                                    iconColor.withOpacity(0.05),
                                                border: Border.all(
                                                    width: 1.625,
                                                    color: iconColor),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(6))),
                                            child: _icon.display(
                                                size: 48, color: iconColor));
                                      }),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameController,
                                        maxLength: 20,
                                        decoration: InputDecoration(
                                          labelText: '${t.categories.name} *',
                                          hintText: 'Ex.: Food',
                                        ),
                                        validator: (value) => fieldValidator(
                                            value,
                                            isRequired: true),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                DropdownButtonFormField<CategoryType>(
                                  decoration: InputDecoration(
                                      labelText: '${t.categories.type} *'),
                                  items: [
                                    DropdownMenuItem(
                                        value: CategoryType.I,
                                        child: Text(t.general.income)),
                                    DropdownMenuItem(
                                        value: CategoryType.E,
                                        child: Text(t.general.expense)),
                                    DropdownMenuItem(
                                        value: CategoryType.B,
                                        child: Text(t.categories.both_types))
                                  ],
                                  value: _type,
                                  onChanged: widget.categoryUUID != null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            if (value != null) {
                                              _type = value;
                                            }
                                          });
                                        },
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                Text(t.icon_selector.color)
                              ],
                            ))),
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: colorOptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final colorItem = colorOptions[index];

                          return Container(
                            clipBehavior: Clip.hardEdge,
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            margin: EdgeInsets.only(
                                left: index == 0 ? 16 : 4,
                                right:
                                    index == colorOptions.length - 1 ? 16 : 4),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorHex.get(colorItem),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(onTap: () {
                                      setState(() {
                                        _color = colorItem;
                                      });
                                    }),
                                  ),
                                ),
                                if (colorItem == _color)
                                  Container(
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(47, 255, 255, 255),
                                      ),
                                      child: const Center(
                                          child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )))
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.categoryUUID != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(t.categories.subcategories),
                      ),
                      StreamBuilder(
                        initialData: const <Category>[],
                        stream: CategoryService.instance
                            .getChildCategories(parentId: widget.categoryUUID!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }

                          final childCategories = snapshot.data!;

                          return Column(
                              children: List.generate(childCategories.length,
                                  (index) {
                            final subcategory = childCategories[index];

                            return ListTile(
                                leading: subcategory.icon
                                    .display(color: ColorHex.get(_color)),
                                trailing: PopupMenuButton(
                                  offset: const Offset(0, 48),
                                  itemBuilder: (context) {
                                    return <PopupMenuEntry<String>>[
                                      PopupMenuItem(
                                          value: 'to_category',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(Icons.login),
                                            minLeadingWidth: 26,
                                            title:
                                                Text(t.categories.make_parent),
                                          )),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                          value: 'merge',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading:
                                                const Icon(Icons.merge_type),
                                            minLeadingWidth: 26,
                                            title: Text(t.categories.merge),
                                          )),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(Icons.edit),
                                            minLeadingWidth: 26,
                                            title: Text(t.general.edit),
                                          )),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(Icons.delete),
                                            minLeadingWidth: 26,
                                            title: Text(t.general.delete),
                                          ))
                                    ];
                                  },
                                  onSelected: (String value) {
                                    if (value == 'delete') {
                                      deleteCategory(subcategory.id);
                                    } else if (value == 'to_category') {
                                      makeMainCategory(subcategory);
                                    } else if (value == 'edit') {
                                      openSubcategoryForm(
                                          subcategory: subcategory,
                                          onSubmit: (name, icon) {
                                            CategoryService.instance
                                                .updateCategory(CategoryInDB(
                                                    id: subcategory.id,
                                                    name: name,
                                                    iconId: icon.id,
                                                    parentCategoryID:
                                                        widget.categoryUUID!));
                                          });
                                    }
                                  },
                                ),
                                title: Text(subcategory.name));
                          }));
                        },
                      ),
                      ListTile(
                          leading: const Icon(Icons.add),
                          onTap: () {
                            openSubcategoryForm(onSubmit: (name, icon) {
                              CategoryService.instance.insertCategory(
                                  CategoryInDB(
                                      id: const Uuid().v4(),
                                      name: name,
                                      iconId: icon.id,
                                      parentCategoryID: categoryToEdit!.id));
                            });
                          },
                          title: Text(t.categories.subcategories_add))
                    ]
                  ],
                ),
              ));
  }
}
